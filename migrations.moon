db = require "lapis.db"

{
    [1473201797]: =>
        db.query 'create table security_credentials
            (application_id int primary key unique not null, employee_id varchar(32) not null, password varchar(32) not null, foreign key (application_id) references applications(id) on delete cascade)'
    [1616283083]: =>
        db.query 'alter table applications modify column school varchar(255) not null'
    [1616529953]: =>
        db.query 'drop table security_credentials' -- goodbye jdrustvo!
}
