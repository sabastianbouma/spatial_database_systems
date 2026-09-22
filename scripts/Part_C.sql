/* In Part C we will look at the more precise query of finding points within an
 irregular shaped polygon, such as the actual suburb (Figure 2).
 The test for point-in-polygon is too complex for standard, purely relational
 SQL.
 An alternative is to make use of POSTGIS to extend postgreSQL with spatial
 data types and the spatial query capability.
 Add the POSTGIS extension (if it’s not already set up – if it is, it’ll tell you and all
 is fine). */
CREATE EXTENSION postgis;
-- Please use the create statement below to set up the Suburb table. 
DROP TABLE IF EXISTS SUBURB;
CREATE TABLE SUBURB (
    Suburb VARCHAR(18),
    SSC_code NUMERIC(4),
    Shape GEOMETRY('POLYGON', 28350),
    CONSTRAINT suburbPK PRIMARY KEY (Suburb)
);
/* Assume that there is only one record for each suburb name.
 A feature point or feature site is a place of interest for train travellers. For
 example, features in these tables could include tourist attractions, sports
 venues, cultural centres, hospitals and educational institutions. Some sites and
 points are related. For instance, Royal Perth Showgrounds would be a feature
 site as it covers a large area but it may have several related feature points for
 each of its entrances.
 Please use the following create table statements to set them up: */
DROP TABLE IF EXISTS FEATURESITE;
CREATE TABLE FEATURESITE (
    Name VARCHAR(40),
    Short_name VARCHAR(20),
    Feature_id NUMERIC(3),
    Shape GEOMETRY('POLYGON', 28350),
    CONSTRAINT fSitePK PRIMARY KEY (Feature_id)
);
DROP TABLE IF EXISTS FEATUREPOINT;
CREATE TABLE FEATUREPOINT (
    Name VARCHAR(30),
    Feature_point_id NUMERIC(3),
    Feature_id NUMERIC(3),
    Position GEOMETRY('POINT', 28350),
    CONSTRAINT fPointPK PRIMARY KEY (Feature_point_id),
    CONSTRAINT fPtSiteFK FOREIGN KEY (Feature_id) REFERENCES FeatureSite (Feature_id)
);
/* Task 1
 Insert some (somewhat) artificial data into the tables. */
INSERT INTO SUBURB (Suburb, SSC_code, Shape)
VALUES (
        'Perth',
        5684,
        ST_GEOMFROMTEXT(
            'POLYGON((391209 6464720,390919 6463010,392833 6463280,392902 6464290,391209 6464720))'
        )
    ),
    (
        'West Perth',
        5915,
        ST_GEOMFROMTEXT(
            'POLYGON((391209 6464720,390601 6465380,388158 6462760,389259 6460250,389372 6461870,390919 6463010,391209 6464720))'
        )
    );
INSERT INTO FEATURESITE (Name, Short_name, Feature_id, Shape)
VALUES (
        'Kings Park Botanical Gardens',
        'Kings Park',
        01,
        ST_GEOMFROMTEXT(
            'POLYGON((390845 6464092,389756 6464429,388415 6463055,388300 6462792,388317 6461851,389210 6461975,389854 6462269,390951 6463227, 390845 6464092))'
        )
    ),
    (
        'Shenton Park',
        'Shenton Park',
        02,
        ST_MAKEENVELOPE(387592, 6463375, 387910, 6463691)
    ),
    (
        'Perth Convention and Exhibition Centre',
        'Convention Centre',
        03,
        ST_MAKEENVELOPE(391353, 6463695, 391753, 6463864)
    );
INSERT INTO FEATUREPOINT (Name, Feature_point_id, Feature_id, Position)
VALUES (
        'Kings Park Main Garden',
        01,
        01,
        ST_GEOMFROMTEXT('POINT(390543 6463279)')
    ),
    (
        'DNA Tower',
        02,
        01,
        ST_GEOMFROMTEXT('POINT(390032 6462929)')
    ),
    (
        'Lotterywest Family Area',
        03,
        01,
        ST_GEOMFROMTEXT('POINT(390300 6462989)')
    ),
    (
        'Mueller Playground',
        04,
        02,
        ST_GEOMFROMTEXT('POINT(387599 6463399)')
    );
/* Task 2
 After you’ve done all of the inserts, create a spatial index of type GIST on each
 of the three tables. */
CREATE INDEX suburb_index ON SUBURB USING GIST (Shape);
CREATE INDEX featuresite_index ON FEATURESITE USING GIST (Shape);
CREATE INDEX featurepoint_index ON FEATUREPOINT USING GIST (Position);
/* Task 3
 Create a connection to your database in ArcMap/ArcPRO or QGIS – your
 choice! Bring all three layers into view. Save the project as your full name (e.g.
 Todd_Robinson). Provide a screenshot of ArcMap/ArcPRO/QGIS (showing as a
 minimum - your layers, the project name, and the table of contents window). */
/* Task 4
 Write the spatial SQL statement to return the name of all feature points
 together with (where it exists) the short name of the point's associated feature
 site(s). */
SELECT fp.Name AS Feature_Point_Name,
    fs.Short_name AS Feature_Site_Short_name
FROM FEATUREPOINT fp
    LEFT JOIN FEATURESITE fs ON fp.Feature_id = fs.Feature_id;
/* Task 5
 Write a spatial SQL statement to return the name of all feature points (not
 feature sites) that fall within the suburb of West Perth. */
SELECT fp.Name AS Feature_Point_Name
FROM FEATUREPOINT fp
    JOIN SUBURB s ON ST_Within(fp.Position, s.Shape)
WHERE s.Suburb = 'West Perth';