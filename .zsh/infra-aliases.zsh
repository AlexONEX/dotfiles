alias aws-dev='aws sso login --profile development'
alias aws-prod='aws sso login --profile production'
alias aws-whoami='aws sts get-caller-identity'
alias aws-profiles='aws configure list-profiles'
alias aws-tail-dev='function _aws_tail_dev() { aws logs tail --profile development --follow "$1"; }; _aws_tail_dev'
alias aws-tail-prod='function _aws_tail_prod() { aws logs tail --profile production --follow "$1"; }; _aws_tail_prod'
alias aws-status='aws sts get-caller-identity 2>&1 || echo "Not logged in or credentials expired"'
clogs-dev() {
	aws logs tail "$1" --since 1d --format short --profile development >output.txt
}
clogs-prod() {
	aws logs tail "$1" --since 1d --format short --profile production >output.txt
}

aws-with() {
	local profile=$1
	shift
	AWS_PROFILE=$profile aws "$@"
}

aws-use() {
	export AWS_PROFILE=$1
	echo "AWS Profile set to: $AWS_PROFILE"
}

tf-init-dev() {
	local project_name=$(basename "$PWD")
	local region="us-east-1"
	terraform init \
		-backend-config="bucket=allaria-development-tf-remote-state" \
		-backend-config="key=allaria-tech/${project_name}/${region}/terraform.tfstate" \
		-backend-config="region=${region}"
}

tf-init-dev-bra() {
	local project_name=$(basename "$PWD")
	local region="sa-east-1"
	terraform init \
		-backend-config="bucket=allaria-development-tf-remote-state" \
		-backend-config="key=allaria-tech/${project_name}/${region}/terraform.tfstate" \
		-backend-config="region=us-east-1"
}

tf-plan-dev() {
	local project_name=$(basename "$PWD")
	terraform plan -no-color \
		-var-file="profiles/development.tfvars" \
		-var "default_tags={Environment = \"development\", Repository = \"allaria-tech/${project_name}\"}"
}

tf-apply-dev() {
	local project_name=$(basename "$PWD")
	terraform apply -no-color \
		-var-file="profiles/development.tfvars" \
		-var "default_tags={Environment = \"development\", Repository = \"allaria-tech/${project_name}\", ManagedBy = \"terraform\", TeamName = \"$(grep team_name profiles/development.tfvars | cut -d'"' -f2)\"}"
}

tf-init-prod() {
	local project_name=$(basename "$PWD")
	local region="us-east-1"
	terraform init \
		-backend-config="bucket=allaria-production-tf-remote-state" \
		-backend-config="key=allaria-tech/${project_name}/${region}/terraform.tfstate" \
		-backend-config="region=${region}"
}

tf-init-prod-bra() {
	local project_name=$(basename "$PWD")
	local region="sa-east-1"
	terraform init \
		-backend-config="bucket=allaria-production-tf-remote-state" \
		-backend-config="key=allaria-tech/${project_name}/${region}/terraform.tfstate" \
		-backend-config="region=us-east-1"
}

tf-apply-prod() {
	local project_name=$(basename "$PWD")
	terraform apply -no-color \
		-var-file="profiles/production.tfvars" \
		-var "default_tags={Environment = \"production\", Repository = \"allaria-tech/${project_name}\", ManagedBy = \"terraform\", TeamName = \"$(grep team_name profiles/development.tfvars | cut -d'"' -f2)\"}"
}

tf-apply-prod-bra() {
	local project_name=$(basename "$PWD")
	AWS_REGION=sa-east-1 terraform apply -no-color -var-file="profiles/production.tfvars" \
		-var "default_tags={Environment = \"production\", Repository = \"allaria-tech/${project_name}\", ManagedBy = \"terraform\", TeamName = \"platform\"}"
}

tf-destroy-dev() {
	local project_name=$(basename "$PWD")
	terraform destroy \
		-var "default_tags={Environment = \"development\", Repository = \"allaria-tech/${project_name}\"}"
}

tf-destroy-prd() {
	local project_name=$(basename "$PWD")
	terraform destroy \
		-var "default_tags={Environment = \"production\", Repository = \"allaria-tech/${project_name}\"}"
}

dynamo-scan() {
	if [ -z "$1" ]; then
		echo "Usage: dynamo-scan <nombre-de-la-tabla>" >&2
		return 1
	fi
	local TABLE_NAME="$1"
	if ! command -v aws &>/dev/null || ! command -v jq &>/dev/null; then
		echo "Error: aws-cli and jq must be installed and in your PATH." >&2
		return 1
	fi

	echo "--> Scanning DynamoDB table '$TABLE_NAME'..."
	local SCAN_RESULT=$(aws dynamodb scan --table-name "$TABLE_NAME" --output json)
	if [ $? -ne 0 ]; then
		echo "Error: Could not find table '$TABLE_NAME'. Are you in the correct region?" >&2
		return 1
	fi
	echo "   Total items found: $(echo "$SCAN_RESULT" | jq '.Count')"
	echo "$SCAN_RESULT" | jq -r '.Items[] | @json' | while read -r item; do
		echo "    $item"
	done
}

dynamo-truncate() {
	if ! command -v aws &>/dev/null || ! command -v jq &>/dev/null; then
		echo "Ensure aws-cli and jq are installed and in your PATH." >&2
		return 1
	fi
	if [ -z "$1" ]; then
		echo "Usage: dynamo-truncate <table-name>" >&2
		return 1
	fi

	local TABLE_NAME="$1"
	local KEY_SCHEMA
	local PARTITION_KEY
	local SORT_KEY
	local PROJECTION_EXPRESSION
	local ITEMS_TO_DELETE

	echo "--> Truncating DynamoDB table '$TABLE_NAME'..."
	KEY_SCHEMA=$(aws dynamodb describe-table --table-name "$TABLE_NAME" 2>/dev/null)
	if [ $? -ne 0 ]; then
		echo "Error: Could not find table '$TABLE_NAME'. Are you in the correct region?" >&2
		return 1
	fi

	PARTITION_KEY=$(echo "$KEY_SCHEMA" | jq -r '.Table.KeySchema[] | select(.KeyType=="HASH") | .AttributeName')
	SORT_KEY=$(echo "$KEY_SCHEMA" | jq -r '.Table.KeySchema[] | select(.KeyType=="RANGE") | .AttributeName')
	echo "   Hash Key (PARTITION): $PARTITION_KEY"
	[ -n "$SORT_KEY" ] && echo "    Llave de Ordenamiento (RANGE): $SORT_KEY"
	[ -n "$SORT_KEY" ] && PROJECTION_EXPRESSION="$PARTITION_KEY,$SORT_KEY" || PROJECTION_EXPRESSION="$PARTITION_KEY"

	echo "--> Scanning items to delete from table '$TABLE_NAME'..."
	ITEMS_TO_DELETE=$(aws dynamodb scan --table-name "$TABLE_NAME" --projection-expression "$PROJECTION_EXPRESSION" | jq -c '.Items[]')
	if [ -z "$ITEMS_TO_DELETE" ]; then
		echo "No items found in table '$TABLE_NAME'. Nothing to delete."
		return 0
	fi

	local -a batch_items=()
	local error_occurred=0

	_delete_batch() {
		local batch_json
		local request_items
		request_items=$(printf '{"DeleteRequest":{"Key":%s}},' "${batch_items[@]}")
		batch_json="{\"RequestItems\": {\"$TABLE_NAME\": [${request_items%,}]}}"

		echo "Deleting batch of items from table '$TABLE_NAME'..."
		aws dynamodb batch-write-item --cli-input-json "$batch_json"
		if [ $? -ne 0 ]; then
			error_occurred=1
		fi
	}

	echo "$ITEMS_TO_DELETE" | while read -r item; do
		batch_items+=("$item")
		if ((${#batch_items[@]} == 25)); then
			_delete_batch
			[ "$error_occurred" -eq 1 ] && break
			batch_items=()
		fi
	done

	if [ "$error_occurred" -eq 0 ] && ((${#batch_items[@]} > 0)); then
		_delete_batch
	fi

	if [ "$error_occurred" -eq 0 ]; then
		echo "Cleaned up the table '$TABLE_NAME' successfully."
	else
		echo "Error occurred while deleting items from the table '$TABLE_NAME'. Some items may not have been deleted."
		return 1
	fi
}

dynamo-delete-item() {
	if ! command -v aws &>/dev/null; then
		echo "Error: aws-cli is not installed or not in your PATH." >&2
		return 1
	fi

	if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
		echo "Usage: dynamo-delete-item <table-name> <key-name> <key-value> [key-type]" >&2
		return 1
	fi

	local table_name="$1"
	local key_name="$2"
	local key_value="$3"
	local key_type="${4:-S}"

	local key_json
	key_json=$(printf '{"%s": {"%s": "%s"}}' "$key_name" "$key_type" "$key_value")

	echo "--> Attempting to delete item from table '$table_name' with key: $key_json"

	aws dynamodb delete-item \
		--table-name "$table_name" \
		--key "$key_json"

	if [ $? -eq 0 ]; then
		echo "Successfully sent delete request for key '$key_name = $key_value'."
		echo "Note: The command succeeds even if the item did not exist."
	else
		echo "Error: Delete request failed." >&2
		echo "Please check your AWS credentials, region, and table details." >&2
		return 1
	fi
}
alias db-marketdata-dev='mycli -h $DB_MARKET_DATA_DEV_HOST -P 3306 -u $DB_MARKET_DATA_DEV_USERNAME -p$DB_MARKET_DATA_DEV_PASS'

download_rds_logs() {
	local date=$1
	local start_hour=$2
	local end_hour=$3
	local db_instance=${4:-"cometa"}
	local profile=${5:-"development"}

	if [[ -z "$date" || -z "$start_hour" || -z "$end_hour" ]]; then
		echo "Uso: download_rds_logs YYYY-MM-DD start_hour end_hour [db_instance] [profile]"
		echo "Ejemplo: download_rds_logs 2025-12-12 16 23"
		return 1
	fi

	for hour in {$start_hour..$end_hour}; do
		local hour_formatted=$(printf '%02d' $hour)
		local log_file="error/postgresql.log.${date}-${hour_formatted}"
		local output_file="logs-${date}-${hour_formatted}.txt"

		aws rds download-db-log-file-portion \
			--db-instance-identifier "$db_instance" \
			--log-file-name "$log_file" \
			--profile "$profile" \
			--output text >"$output_file"
	done
	echo "Logs descargados para ${date} desde hora ${start_hour} hasta ${end_hour}"
}

redshift-metrics() {
	PATTERN=$1
	PROFILE=${AWS_PROFILE:-development}

	# Obtener todos los clusters con su info
	CLUSTER_INFO=$(aws redshift describe-clusters --profile $PROFILE --query 'Clusters[*].[ClusterIdentifier,DBName,MasterUsername]' --output text)

	if [ -z "$CLUSTER_INFO" ]; then
		echo "No se encontraron clusters de Redshift"
		return 1
	fi

	# Recolectar todas las DBs de todos los clusters
	typeset -a all_options
	i=1

	while IFS=$'\t' read -r cluster_id primary_db db_user; do
		# Obtener todas las DBs del cluster como JSON y parsear
		DBS=$(aws redshift-data list-databases --profile $PROFILE --cluster-identifier "$cluster_id" --database "$primary_db" --db-user "$db_user" --query 'Databases' --output json 2>/dev/null)

		if [ -n "$DBS" ]; then
			# Parsear el JSON y agregar cada DB
			for db in $(echo "$DBS" | grep -o '"[^"]*"' | tr -d '"'); do
				# Filtrar DBs de sistema
				if [[ "$db" != "sys:internal" ]] && [[ "$db" != "awsdatacatalog" ]] && [[ -n "$db" ]]; then
					all_options[$i]="$cluster_id:$db"
					((i++))
				fi
			done
		fi
	done <<<"$CLUSTER_INFO"

	# Si no se pasó patrón, mostrar todas las opciones
	if [ -z "$PATTERN" ]; then
		echo "Clusters y bases de datos disponibles:"
		echo "======================================"
		echo ""

		for idx in "${!all_options[@]}"; do
			IFS=':' read -r cluster_id db_name <<<"${all_options[$idx]}"
			echo "$idx) $cluster_id -> $db_name"
		done

		echo ""
		read -p "Selecciona un número: " selection

		if [ -z "$selection" ] || [ -z "${all_options[$selection]}" ]; then
			echo "Selección inválida"
			return 1
		fi

		IFS=':' read -r CLUSTER DBNAME <<<"${all_options[$selection]}"
	else
		# Buscar DB que coincida con el patrón
		CLUSTER=""
		DBNAME=""

		for opt in "${all_options[@]}"; do
			IFS=':' read -r cluster_id db_name <<<"$opt"
			if [[ "$db_name" == *"$PATTERN"* ]] || [[ "$cluster_id" == *"$PATTERN"* ]]; then
				CLUSTER=$cluster_id
				DBNAME=$db_name
				break
			fi
		done

		if [ -z "$CLUSTER" ]; then
			echo "No se encontró ningún cluster o DB que coincida con: $PATTERN"
			echo ""
			echo "Opciones disponibles:"
			for opt in "${all_options[@]}"; do
				IFS=':' read -r cluster_id db_name <<<"$opt"
				echo "  - $cluster_id -> $db_name"
			done
			return 1
		fi
	fi

	echo "Cluster: $CLUSTER"
	echo "Base de datos: $DBNAME"
	echo ""

	START_TIME=$(date -u -v-1H +%Y-%m-%dT%H:%M:%S)
	END_TIME=$(date -u +%Y-%m-%dT%H:%M:%S)
	PERIOD=300

	echo "=========================================="
	echo "Métricas para: $CLUSTER ($DBNAME)"
	echo "Período: Última hora"
	echo "=========================================="

	# Array de métricas
	METRICS=(
		"CPUUtilization"
		"DatabaseConnections"
		"PercentageDiskSpaceUsed"
		"ReadLatency"
		"WriteLatency"
		"ReadThroughput"
		"WriteThroughput"
		"NetworkReceiveThroughput"
		"NetworkTransmitThroughput"
		"HealthStatus"
		"MaintenanceMode"
	)

	# Iterar sobre cada métrica
	for METRIC in "${METRICS[@]}"; do
		echo ""
		echo "--- $METRIC ---"
		aws cloudwatch get-metric-statistics \
			--profile $PROFILE \
			--namespace AWS/Redshift \
			--metric-name "$METRIC" \
			--dimensions Name=ClusterIdentifier,Value="$CLUSTER" \
			--start-time "$START_TIME" \
			--end-time "$END_TIME" \
			--period "$PERIOD" \
			--statistics Average,Maximum \
			--query 'Datapoints[*].[Timestamp,Average,Maximum]' \
			--output table 2>/dev/null || echo "No hay datos disponibles"
	done

	echo ""
	echo "=========================================="
	echo "Información general del clúster"
	echo "=========================================="
	aws redshift describe-clusters \
		--profile $PROFILE \
		--cluster-identifier "$CLUSTER" \
		--query 'Clusters[0].[ClusterIdentifier,ClusterStatus,NodeType,NumberOfNodes,ClusterAvailabilityStatus]' \
		--output table
}

download_rds_logs() {
	local date=$1
	local start_hour=$2
	local end_hour=$3
	local db_name_pattern=${4:-"cometa"}
	local profile=${5:-"development"}

	if [[ -z "$date" || -z "$start_hour" || -z "$end_hour" ]]; then
		echo "Uso: download_rds_logs YYYY-MM-DD start_hour end_hour [db_name] [profile]"
		echo "Ejemplo: download_rds_logs 2025-12-12 16 23 cometa development"
		return 1
	fi

	# Buscar instancia RDS que tenga la DB
	echo "Buscando instancia RDS con base de datos '$db_name_pattern'..."

	local db_instance=""
	local instances=$(aws rds describe-db-instances --profile "$profile" --query 'DBInstances[*].[DBInstanceIdentifier,DBName]' --output text)

	while IFS=$'\t' read -r instance_id db_name; do
		if [[ "$db_name" == *"$db_name_pattern"* ]] || [[ "$instance_id" == *"$db_name_pattern"* ]]; then
			db_instance=$instance_id
			echo "Encontrada instancia: $db_instance (DB: $db_name)"
			break
		fi
	done <<<"$instances"

	if [ -z "$db_instance" ]; then
		echo "No se encontró ninguna instancia RDS con DB '$db_name_pattern'"
		echo ""
		echo "Instancias disponibles:"
		echo "$instances" | while IFS=$'\t' read -r instance_id db_name; do
			echo "  - $instance_id -> $db_name"
		done
		return 1
	fi

	echo "Descargando logs de $date desde hora $start_hour hasta $end_hour..."
	echo ""

	for hour in $(seq $start_hour $end_hour); do
		local hour_formatted=$(printf '%02d' $hour)
		local log_file="error/postgresql.log.${date}-${hour_formatted}"
		local output_file="logs-${date}-${hour_formatted}.txt"

		echo "Descargando: $log_file -> $output_file"
		aws rds download-db-log-file-portion \
			--db-instance-identifier "$db_instance" \
			--log-file-name "$log_file" \
			--profile "$profile" \
			--output text >"$output_file" 2>/dev/null

		if [ $? -eq 0 ]; then
			echo "  [OK] Descargado ($(wc -l <"$output_file") líneas)"
		else
			echo "  [ERROR] Error al descargar"
		fi
	done

	echo ""
	echo "Logs descargados para ${date} desde hora ${start_hour} hasta ${end_hour}"
}

trigger_alarm() {
	local PROFILE="${AWS_PROFILE:-development}"

	echo "Fetching all CloudWatch alarms..."
	echo ""

	# Get all alarms and format them nicely
	local alarms=$(aws cloudwatch describe-alarms \
		--profile "$PROFILE" \
		--query 'MetricAlarms[*].[AlarmName,StateValue]' \
		--output text | sort)

	if [ -z "$alarms" ]; then
		echo "No alarms found."
		return 1
	fi

	# Create array for alarm names
	local alarm_names=()
	local i=1

	while IFS=$'\t' read -r name state; do
		alarm_names+=("$name")
		echo "$i) [$state] $name"
		((i++))
	done <<<"$alarms"

	echo ""
	read -p "Select alarm number to trigger (or 0 to cancel): " selection

	if [ "$selection" -eq 0 ]; then
		echo "Cancelled."
		return 0
	fi

	if [ "$selection" -lt 1 ] || [ "$selection" -gt ${#alarm_names[@]} ]; then
		echo "Invalid selection."
		return 1
	fi

	local selected_alarm="${alarm_names[$((selection - 1))]}"

	echo ""
	echo "Triggering alarm: $selected_alarm"

	aws cloudwatch set-alarm-state \
		--profile "$PROFILE" \
		--alarm-name "$selected_alarm" \
		--state-value ALARM \
		--state-reason "Testing"

	echo ""
	echo "[OK] Alarm '$selected_alarm' triggered with state ALARM"
	echo "Check Discord for the notification!"
}

# ECS Fargate Service Metrics
ecs-stats() {
	local service_name=$1
	local days=${2:-1}

	if [ -z "$service_name" ]; then
		echo "Usage: ecs-stats <service-name> [days]"
		echo "Example: ecs-stats cometa"
		echo "Example: ecs-stats cometa 7  # últimos 7 días"
		return 1
	fi

	local cluster="services-fargate-spot"
	local limit=$((days * 288)) # 288 datapoints por día (5 min intervals)
	if [ $limit -gt 100 ]; then
		limit=100
	fi

	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	echo "  ECS Service: $service_name"
	echo "  Cluster: $cluster"
	echo "  Period: Last $days day(s)"
	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	echo ""

	echo "CPU Utilization (%) - showing last $limit datapoints:"
	AWS_PROFILE=development aws cloudwatch get-metric-statistics \
		--namespace AWS/ECS \
		--metric-name CPUUtilization \
		--dimensions Name=ServiceName,Value=$service_name Name=ClusterName,Value=$cluster \
		--start-time $(date -u -v-${days}d +%Y-%m-%dT%H:%M:%S) \
		--end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
		--period 300 \
		--statistics Minimum Average Maximum \
		--query "Datapoints|sort_by(@,&Timestamp)[-${limit}:].[Timestamp,Minimum,Average,Maximum]" \
		--output table

	echo ""
	echo "Memory Utilization (%) - showing last $limit datapoints:"
	AWS_PROFILE=development aws cloudwatch get-metric-statistics \
		--namespace AWS/ECS \
		--metric-name MemoryUtilization \
		--dimensions Name=ServiceName,Value=$service_name Name=ClusterName,Value=$cluster \
		--start-time $(date -u -v-${days}d +%Y-%m-%dT%H:%M:%S) \
		--end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
		--period 300 \
		--statistics Minimum Average Maximum \
		--query "Datapoints|sort_by(@,&Timestamp)[-${limit}:].[Timestamp,Minimum,Average,Maximum]" \
		--output table
}

# RDS Instance Metrics
rds-stats() {
	local db_instance=$1
	local days=${2:-1}

	if [ -z "$db_instance" ]; then
		echo "Usage: rds-stats <db-instance-name> [days]"
		echo "Example: rds-stats cometa"
		echo "Example: rds-stats cometa 7  # últimos 7 días"
		return 1
	fi

	local limit=$((days * 288)) # 288 datapoints por día (5 min intervals)
	if [ $limit -gt 100 ]; then
		limit=100
	fi

	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	echo "  RDS Instance: $db_instance"
	echo "  Period: Last $days day(s)"
	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	echo ""

	echo "CPU Utilization (%) - showing last $limit datapoints:"
	AWS_PROFILE=development aws cloudwatch get-metric-statistics \
		--namespace AWS/RDS \
		--metric-name CPUUtilization \
		--dimensions Name=DBInstanceIdentifier,Value=$db_instance \
		--start-time $(date -u -v-${days}d +%Y-%m-%dT%H:%M:%S) \
		--end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
		--period 300 \
		--statistics Minimum Average Maximum \
		--query "Datapoints|sort_by(@,&Timestamp)[-${limit}:].[Timestamp,Minimum,Average,Maximum]" \
		--output table

	echo ""
	echo "Freeable Memory (bytes - divide by 1048576 for MB) - showing last $limit datapoints:"
	AWS_PROFILE=development aws cloudwatch get-metric-statistics \
		--namespace AWS/RDS \
		--metric-name FreeableMemory \
		--dimensions Name=DBInstanceIdentifier,Value=$db_instance \
		--start-time $(date -u -v-${days}d +%Y-%m-%dT%H:%M:%S) \
		--end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
		--period 300 \
		--statistics Minimum Average Maximum \
		--query "Datapoints|sort_by(@,&Timestamp)[-${limit}:].[Timestamp,Minimum,Average,Maximum]" \
		--output table

	echo ""
	echo "Free Storage Space (bytes - divide by 1073741824 for GB) - showing last $limit datapoints:"
	AWS_PROFILE=development aws cloudwatch get-metric-statistics \
		--namespace AWS/RDS \
		--metric-name FreeStorageSpace \
		--dimensions Name=DBInstanceIdentifier,Value=$db_instance \
		--start-time $(date -u -v-${days}d +%Y-%m-%dT%H:%M:%S) \
		--end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
		--period 300 \
		--statistics Minimum Average Maximum \
		--query "Datapoints|sort_by(@,&Timestamp)[-${limit}:].[Timestamp,Minimum,Average,Maximum]" \
		--output table

	echo ""
	echo "Database Connections - showing last $limit datapoints:"
	AWS_PROFILE=development aws cloudwatch get-metric-statistics \
		--namespace AWS/RDS \
		--metric-name DatabaseConnections \
		--dimensions Name=DBInstanceIdentifier,Value=$db_instance \
		--start-time $(date -u -v-${days}d +%Y-%m-%dT%H:%M:%S) \
		--end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
		--period 300 \
		--statistics Minimum Average Maximum \
		--query "Datapoints|sort_by(@,&Timestamp)[-${limit}:].[Timestamp,Minimum,Average,Maximum]" \
		--output table

	echo ""
	echo "Tip: For db.t3.micro, total RAM is 1024 MB (1073741824 bytes)"
	echo "     Free Memory of 50-100 MB means you're using 90-95% RAM"
}

# ECS Autoscaling Status
ecs-scaling() {
	local service_name=$1
	local max_results=${2:-10}

	if [ -z "$service_name" ]; then
		echo "Usage: ecs-scaling <service-name> [max-results]"
		echo "Example: ecs-scaling cometa"
		echo "Example: ecs-scaling cometa 50  # últimas 50 actividades"
		return 1
	fi

	local cluster="services-fargate-spot"
	local resource_id="service/$cluster/$service_name"

	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	echo "  ECS Autoscaling Status: $service_name"
	echo "  Cluster: $cluster"
	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	echo ""

	echo "Scalable Target:"
	AWS_PROFILE=development aws application-autoscaling describe-scalable-targets \
		--service-namespace ecs \
		--resource-ids "$resource_id" \
		--query 'ScalableTargets[0].[MinCapacity,MaxCapacity,ResourceId]' \
		--output table

	echo ""
	echo "Scaling Policies:"
	AWS_PROFILE=development aws application-autoscaling describe-scaling-policies \
		--service-namespace ecs \
		--resource-id "$resource_id" \
		--query 'ScalingPolicies[*].[PolicyName,PolicyType,Alarms[0].AlarmName]' \
		--output table

	echo ""
	echo "CloudWatch Alarms:"
	AWS_PROFILE=development aws cloudwatch describe-alarms \
		--alarm-names "${service_name}-cpu-high" "${service_name}-cpu-low" \
		--query 'MetricAlarms[*].[AlarmName,StateValue,Threshold,ComparisonOperator,EvaluationPeriods]' \
		--output table

	echo ""
	echo "Recent Scaling Activity (last $max_results):"
	AWS_PROFILE=development aws application-autoscaling describe-scaling-activities \
		--service-namespace ecs \
		--resource-id "$resource_id" \
		--max-results $max_results \
		--query 'ScalingActivities[*].[StartTime,Description,StatusCode,StatusMessage]' \
		--output table
}

alias delete-secret='aws secretsmanager delete-secret --secret-id "application/piggy" --force-delete-without-recovery 2>&1'

alias bcra-api='curl https://api.bcra.gob.ar/estadisticas/v4.0/Monetarias > output.json'

cwgrep() {
  local LOG_GROUP=$1
  local PATTERN=$2
  local START_TIME=$(( ($(date +%s) - 172800) * 1000 ))
  local ESCAPED_PATTERN="\"$PATTERN\""
  aws logs filter-log-events --log-group-name "$LOG_GROUP" --filter-pattern "$ESCAPED_PATTERN" --start-time "$START_TIME" --query 'events[].message' --output text
}

cwlogs() {
  local log_group=""
  local profile=""
  local start_time=""
  local end_time=""
  local OPTIND=1

  while getopts "p:s:e:" opt; do
    case $opt in
      p) profile="$OPTARG" ;;
      s) start_time="$OPTARG" ;;
      e) end_time="$OPTARG" ;;
      *) echo "Usage: cwlogs -p <profile> -s <start-time> -e <end-time> <log-group>"; return 1 ;;
    esac
  done
  shift $((OPTIND - 1))

  log_group="$1"

  if [[ -z "$log_group" ]]; then
    echo "Usage: cwlogs -p <profile> -s <start-time> -e <end-time> <log-group>"
    return 1
  fi

  local start_ms=$(TZ="America/Argentina/Buenos_Aires" date -j -f "%Y-%m-%d %H:%M:%S" "$start_time" "+%s000")
  local end_ms=$(TZ="America/Argentina/Buenos_Aires" date -j -f "%Y-%m-%d %H:%M:%S" "$end_time" "+%s000")

  aws logs filter-log-events \
    --log-group-name "$log_group" \
    --profile "$profile" \
    --region us-east-1 \
    --start-time "$start_ms" \
    --end-time "$end_ms" \
    | jq -r '.events[].message'
}

cwtail() {
  local log_group="$1"
  local profile="$2"

  aws logs tail "$log_group" \
    --profile "$profile" \
    --region us-east-1 \
    --follow \
    --format short
}

cwgroups() {
  local profile=""
  local OPTIND=1

  while getopts "p:" opt; do
    case $opt in
      p) profile="$OPTARG" ;;
      *) echo "Usage: cwgroups -p <profile>"; return 1 ;;
    esac
  done

  if [[ -z "$profile" ]]; then
    echo "Usage: cwgroups -p <profile>"
      return 1
  fi

  aws logs describe-log-groups \
    --profile "$profile" \
    --region us-east-1 \
    | jq -r '.logGroups[].logGroupName'
}

# Search CloudWatch logs by request ID
clreq() {
  local log_group=""
  local request_id=""
  local profile="${AWS_PROFILE:-development}"
  local start_time=""
  local end_time=""
  local minutes=30
  local OPTIND=1

  while getopts "s:e:m:" opt; do
    case $opt in
      s) start_time="$OPTARG" ;;
      e) end_time="$OPTARG" ;;
      m) minutes="$OPTARG" ;;
      *)
        echo "Usage: clreq [-m <minutes>] [-s <start-time>] [-e <end-time>] <log-group> <request-id>"
        echo ""
        echo "Uses \$AWS_PROFILE environment variable (current: ${AWS_PROFILE:-development})"
        echo ""
        echo "Examples:"
        echo "  clreq market-data market-data-kr3a9iOF                    # last 30 min"
        echo "  clreq -m 120 market-data market-data-kr3a9iOF             # last 2 hours"
        echo "  clreq -s '2026-05-13 10:00:00' -e '2026-05-13 11:00:00' market-data market-data-kr3a9iOF"
        return 1
        ;;
    esac
  done
  shift $((OPTIND - 1))

  log_group="$1"
  request_id="$2"

  if [[ -z "$log_group" ]] || [[ -z "$request_id" ]]; then
    echo "Error: log-group and request-id are required"
    echo ""
    echo "Usage: clreq [-p <profile>] [-s <start-time>] [-e <end-time>] <log-group> <request-id>"
    echo ""
    echo "Examples:"
    echo "  clreq market-data market-data-kr3a9iOF"
    echo "  clreq -p production market-data market-data-kr3a9iOF"
    return 1
  fi

  # Set time range
  local start_ms
  local end_ms

  if [[ -n "$start_time" ]] && [[ -n "$end_time" ]]; then
    start_ms=$(TZ="America/Argentina/Buenos_Aires" date -j -f "%Y-%m-%d %H:%M:%S" "$start_time" "+%s000")
    end_ms=$(TZ="America/Argentina/Buenos_Aires" date -j -f "%Y-%m-%d %H:%M:%S" "$end_time" "+%s000")
    local time_info="custom range"
  else
    # Default: last N minutes
    end_ms=$(date +%s)000
    start_ms=$(( end_ms - (minutes * 60 * 1000) ))
    local time_info="last $minutes min"
  fi

  local args=(
    --log-group-name "$log_group"
    --filter-pattern "$request_id"
    --profile "$profile"
    --region us-east-1
    --start-time "$start_ms"
    --end-time "$end_ms"
  )

  echo "Searching $log_group for request-id: $request_id (profile: $profile, $time_info)..."
  echo ""

  aws logs filter-log-events "${args[@]}" | jq -r '.events[].message'
}

# Docker
function docker-clean() {
  docker ps -aq | xargs -r docker stop
  docker ps -aq | xargs -r docker rm
  docker volume ls -q | xargs -r docker volume rm
}

function docker-clean-images() {
  docker rmi $(docker images -q)
}
