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



pre-check:
	@echo "Checking go install needed"
	@if [ $(shell which gggg 2>/dev/null || echo FALSE) = "FALSE" ]; then \
		read -p " 跑程式需要go但您目前沒裝 > 要幫你/妳裝嗎? (Y/y): " uinput; \
		if [ "$$uinput" = "" ] || [ "$$uinput" = "Y" ] || [ "$$uinput" = "y" ]; then \
			echo "go installing"; \
		else \
			echo '\n  > run code after go/docker installed\n'; exit 1; \
		fi; \
	fi
	
	@echo "\nChecking docker install needed"
	@if [ $(shell which rrrr 2>/dev/null || echo FALSE) = "FALSE" ]; then \
		read -p " 跑程式需要docker但您目前沒裝 > 要幫你/妳裝嗎? (Y/y): " uinput; \
		if [ "$$uinput" = "" ] || [ "$$uinput" = "Y" ] || [ "$$uinput" = "y" ]; then \
			echo "docker installing"; \
		else \
			echo '\n  > run code after go/docker installed\n'; exit 1; \
		fi; \
	fi

	@echo "\nChecking for docker group "
	@if [ $(shell cat /etc/group | grep docker) ]; then \
		echo yes; \
	else \
		echo "setup docker group"; \
	fi


.PHONY: db psql schema rmdb run select notice test pre-check
.SILENT: db psql schema rmdb run select notice test pre-check