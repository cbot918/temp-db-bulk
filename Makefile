CONTAINER_NAME=temp-postgres
DB_NAME=testbulk
DB_PORT=5433
DB_PASSWORD=12345
# public
## run app
run: db schema
	go run .

## varify result
select:
	docker run -it --rm --network bridge postgres psql -h $(shell docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' temp-postgres) -U postgres -W $(DB_NAME) -c "select * from names order by nconst limit 5;"

## psql cli
psql:
	docker run -it --rm --network bridge postgres psql -h $(shell docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' temp-postgres) -U postgres

notice:
	echo -e '\n如遇docker需要sudo問題的話可以設置 docker group\n\n sudo groupadd docker\n sudo usermod -aG docker $$USER \n newgrp docker \n'

#-------------------
# private 
db:
	docker run --name $(CONTAINER_NAME) -p $(DB_PORT):5432 -e PGPASSWORD=$(DB_PASSWORD) -e POSTGRES_PASSWORD=$(DB_PASSWORD) -e POSTGRES_DB=$(DB_NAME) -d postgres

schema:
	docker run -it --rm --network bridge postgres \
	psql -h $(shell docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' temp-postgres) -U postgres -W $(DB_NAME) -c "CREATE TABLE names (nconst varchar(255), primary_name varchar(255), birth_year varchar(4), death_year varchar(4) DEFAULT '', primary_professions varchar[], known_for_titles varchar[]);"

rmdb:
	docker stop $(CONTAINER_NAME) 
	docker container rm $(CONTAINER_NAME) 

.PHONY: db psql schema rmdb run select notice test
.SILENT: db psql schema rmdb run select notice test