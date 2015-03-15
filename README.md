# docker-gsales

This is docker container for running gsales (see www.gales.de)

## Example

Run a mysql container where gsales can connect to

```bash
docker run -d \
--name gsales-mysql \
-v /path/to/mysql-data:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=xyz \
-p 3306:3306 \
mysql:5.6
```

Create a database and user for gsales

```mysql
CREATE DATABASE gsales;
CREATE USER 'gsales'@'%' IDENTIFIED BY 'PypbytNag9' ;
GRANT ALL ON gsales.* TO 'gsales'@'%' WITH GRANT OPTION ;
```

```bash
docker run -d \
--link gsales-mysql:mysql \
-e MYSQL_HOST=mysql \
-e MYSQL_DATABASE=gsales \
-e MYSQL_USER=gsales \
-e MYSQL_PASSWORD=xyz \
-v /path/to/volume/DATA:/var/www/gsales/DATA \
-p 8080:80 \
hauptmedia/gsales
```
