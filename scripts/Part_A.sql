-- Drop tables if the exist so that the script can be rerun without errors.
DROP TABLE IF EXISTS master CASCADE;
DROP TABLE IF EXISTS station_extension CASCADE;
/*
 Task 1
 Currently, the database contains only one of Perth's train routes: Perth to
 Fremantle. You need to update the database to include the southern line
 (running to Mandurah).
 
 This requires 10 new stationsshown in Table 1 below. Table 1 also shows station
 master’s name (e.g., Cameron Cooper) and their identification in brackets (e.g.,
 64MT943).
 It is quite possible that you might have to do other things (e.g., alter tables) to
 get this to work properly. Use your initiative and do them, reporting what you
 did at each question, but do not add any extra data that you don’t know about. 
 */
/* 1. Create a table called Master using Station_Master as your template (it
 requires the same fields and data types). */
CREATE TABLE IF NOT EXISTS master (
    master_id CHAR(7) NOT NULL,
    last_name VARCHAR(15),
    first_name VARCHAR(15),
    phone_num NUMERIC(9, 0),
    dob DATE
);
/* 2. Add a named primary key constraint to Master (using ID) after constructing
 the table. */
ALTER TABLE master
ADD CONSTRAINT master_master_id_key UNIQUE (master_id);
/* 3. Make the master's surname compulsory. Consider that you have already
 created the table. */
ALTER TABLE master
ALTER COLUMN last_name
SET NOT NULL;
/* 4. Add all the existing data records from Station_Master. Elegance in your
 approach will be considered (e.g., efficient coding). */
INSERT INTO master (master_id, last_name, first_name, phone_num, dob)
SELECT stn_master_id,
    last_name,
    first_name,
    phone_num,
    dob
FROM station_master;
/* 5. Insert the new station master records (only add the data that you know) as
 shown above. */
ALTER TABLE master
ALTER COLUMN last_name TYPE VARCHAR(20),
    ALTER COLUMN first_name TYPE VARCHAR(20);
INSERT INTO master (master_id, first_name, last_name)
VALUES ('64MT943', 'Cameron', 'Cooper'),
    ('85JW156', 'Clair', 'Davey'),
    (
        '79VH346',
        'Diego Fernando',
        'Hernandez Villamil'
    ),
    ('74AP984', 'Wai Kit', 'Lau'),
    ('89QF747', 'Jordan', 'Maddock'),
    ('25SW748', 'Tika Ram', 'Mahatso'),
    ('25SW219', 'Dunusinhege Taniya', 'Nawagamuwa'),
    ('59DQ592', 'Jennifer Ann', 'Potucek'),
    ('26AB623', 'Thinley', 'Paday'),
    ('19OC305', 'Amanda', 'Tevlone');
/* 6. Create a table called Station_Extension from Station ensuring all existing
 records are copied over to Station_Extension. StationID’s are sequential and
 can continue from the last station in the station table. */
CREATE TABLE IF NOT EXISTS station_extension (
    station_extension_id NUMERIC(2, 0),
    station_name VARCHaR(20),
    vertex_id NUMERIC(3, 0),
    max_railcars NUMERIC(1, 0),
    interchange CHAR(1),
    stn_master_id CHAR(7)
);
INSERT INTO station_extension (
        station_extension_id,
        station_name,
        vertex_id,
        max_railcars,
        interchange,
        stn_master_id
    )
SELECT station_id,
    station_name,
    vertex_id,
    max_railcars,
    interchange,
    stn_master_id
FROM station;
-- Create a sequence for station_extension_id to ensure automatic creation of unique IDs for new records.
CREATE SEQUENCE station_extension_id_seq;
SELECT SETVAL(
        'station_extension_id_seq',
        COALESCE(
            (
                SELECT MAX(station_extension_id)::bigint
                FROM station_extension
            ),
            0
        )
    );
ALTER TABLE station_extension
ALTER COLUMN station_extension_id
SET DEFAULT nextval('station_extension_id_seq');
ALTER SEQUENCE station_extension_id_seq OWNED BY station_extension.station_extension_id;
/* 7. Make the station name unique and not-null. */
ALTER TABLE station_extension
ALTER COLUMN station_name
SET NOT NULL,
    ADD CONSTRAINT station_extension_station_name_unique UNIQUE (station_name);
/* 8. Add a named primary key constraint to Station_Extension (using ID). */
ALTER TABLE station_extension
ADD CONSTRAINT station_extension_station_extension_id_key UNIQUE (station_extension_id);
/* 9. Add a named foreign key constraint from Station_Extension to Master. */
ALTER TABLE station_extension
ADD CONSTRAINT station_extension_stn_master_id_fkey FOREIGN KEY (stn_master_id) REFERENCES master(master_id);
/* 10. Insert new records for each of the 10 stations as shown above. If the data
 isn’t provided do not add imaginary data to the table. However, do continue
 the sequence for Station_ID, e.g., Esplanade has Station_ID = 18. */
INSERT INTO station_extension (station_name, stn_master_id)
VALUES ('Esplanade', '64MT943'),
    ('Canning Bridge', '85JW156'),
    ('Bull Creek', '79VH346'),
    ('Murdoch', '74AP984'),
    ('Cockburn Central', '89QF747'),
    ('Kwinana', '25SW748'),
    ('Wellard', '25SW219'),
    ('Rockingham', '59DQ592'),
    ('Warnbro', '26AB623'),
    ('Mandurah', '19OC305');
/* 11. Create a view called StationStaff that lists all station names and IDs from
 the Station_Extension table along with their matching station master and
 station master ID from the Master table, sorted by station name. */
CREATE VIEW stationstaff AS
SELECT se.station_name,
    se.station_extension_id,
    m.first_name,
    m.last_name,
    m.master_id
FROM station_extension se
    JOIN master m ON se.stn_master_id = m.master_id
ORDER BY se.station_name;
SELECT *
FROM stationstaff;