
CREATE TABLE usage(id integer not null, timestamp integer not null, value integer not null, primary key (id, timestamp));
CREATE TABLE stats (timestamp integer not null, average integer, maximum integer, minimum integer, primary key (timestamp));
