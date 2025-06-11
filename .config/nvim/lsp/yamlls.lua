return {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yml", "yaml.docker-compose", "yaml.gitlab" },
	root_markers = { ".git", "." },
	settings = {
		yaml = {
			keyOrdering = false,
			format = {
				enable = true,
			},
			validate = true,
			hover = true,
			completion = true,
			schemas = {
				["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
				["https://json.schemastore.org/github-action.json"] = "/.github/action.{yml,yaml}",
				["https://json.schemastore.org/ansible-stable-2.9.json"] = "roles/tasks/**/*.{yml,yaml}",
				["https://json.schemastore.org/prettierrc.json"] = ".prettierrc.{yml,yaml}",
				["https://json.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
				["https://json.schemastore.org/ansible-playbook.json"] = "*play*.{yml,yaml}",
				["https://json.schemastore.org/chart.json"] = "Chart.{yml,yaml}",
				["https://json.schemastore.org/docker-compose.json"] = "*docker-compose*.{yml,yaml}",
				["https://json.schemastore.org/gitlab-ci.json"] = "*gitlab-ci*.{yml,yaml}",
				["kubernetes"] = "*.k8s.{yml,yaml}",
			},
		},
	},
}
