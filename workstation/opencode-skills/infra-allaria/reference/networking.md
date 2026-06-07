# Allaria VPC Interconnection Reference

## Transit Gateway + VPC Peering

### Huawei Cloud subnets (via TGW)

**Development `us-east-1`:**
```
172.30.96.0/19, 172.26.0.0/16, 172.28.0.0/19, 172.30.160.0/19,
172.30.20.0/24, 172.28.64.0/19 (agro wks chile), 172.27.20.0/24
```

**Development `sa-east-1`:**
```
172.28.0.0/19
```

**Production `us-east-1`:**
```
172.30.96.0/19, 172.26.0.0/16, 172.28.0.0/19, 172.30.160.0/19,
172.30.20.0/24, 172.28.64.0/19, 172.27.20.0/22, 172.26.20.0/24,
10.100.100.0/24 (Quinto Inversiones),
172.20.192.0/19 (Quartier)
```

**Production `sa-east-1`:**
```
172.30.96.0/19, 172.26.0.0/16, 172.28.0.0/19, 172.30.160.0/19,
172.30.20.0/24, 172.28.64.0/19, 172.27.20.0/22, 172.26.20.0/24,
172.20.0.0/19
```

### Allaria 359 / Accelerated VPN subnets (via TGW)

**Development `us-east-1`:**
```
172.23.6.0/24, 172.20.0.0/21, 10.1.1.18/32, 172.20.27.0/24,
172.20.25.0/24, 172.17.10.0/24, 200.42.14.0/24
```

**Production `us-east-1`:**
```
172.23.6.0/24, 172.20.0.0/21, 200.42.14.0/24 (byma),
172.17.0.0/16, 172.20.27.0/24
```

### RioPav subnets (via TGW)

**Development `us-east-1`:**
```
192.168.121.0/24, 192.168.70.0/24, 192.168.7.0/24,
192.168.21.0/24, 172.29.231.0/24, 172.29.238.0/24, 192.168.244.0/24
```

**Production `us-east-1`:**
```
192.168.121.0/24, 192.168.70.0/24, 192.168.7.0/24,
172.29.231.0/24, 172.29.238.0/24, 192.168.21.0/24
```

### Other TGW routes

| Destination | Where | What |
|-------------|-------|------|
| `10.0.0.0/16` | Dev us-east-1 | Allariamas (via TGW) |
| `10.1.0.0/16` | Dev us-east-1 | Allariamas shared (via VPC Peering `pcx-0ed193b6e4878a1b4`) |
| `10.6.0.0/16` | Dev us-east-1 | BYMA |
| `10.11.0.0/16` | Dev us-east-1 | Brazil |
| `10.1.131.31/32` | Dev us-east-1 | Bind API (HW VPN) |
| `10.2.0.0/16` | Prod us-east-1 | Allariamas (via TGW) |
| `10.1.0.0/16` | Prod us-east-1 | Allariamas shared (via VPC Peering `pcx-0307a566d49bb2959`) |
| `10.8.0.0/16` | Prod us-east-1 | BYMA |
| `10.1.101.31/32` | Prod us-east-1 | Bind API (HW VPN) |
| `10.10.0.0/16` | Dev sa-east-1 | Virginia dev VPC |
| `172.28.0.0/19` | Dev sa-east-1 | Huawei Chile |
