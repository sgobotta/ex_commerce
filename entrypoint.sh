#!/bin/sh

/app/bin/ex_commerce eval ExCommerce.Release.create_db
/app/bin/ex_commerce eval ExCommerce.Release.migrate
/app/bin/ex_commerce start
