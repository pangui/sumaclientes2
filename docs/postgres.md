# Load dump

```bash
rails db:drop
rails db:create
psql -U sumaclientes -W -h db sumaclientes < dump.2024-09-20.sql
rails db:migrate
```
