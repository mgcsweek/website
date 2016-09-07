db = require "lapis.db"

{
    [1473201797]: =>
        db.query 'create table security_credentials
            (application_id int primary key unique not null, employee_id varchar(32) not null, password varchar(32) not null, foreign key (application_id) references applications(id) on delete cascade)'
}
