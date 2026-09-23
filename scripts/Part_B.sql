DROP VIEW IF EXISTS V_SUBURBBOUNDS CASCADE;
/* Task 1
 What is the shortest distance between Karrakatta and Perth stations based on
 their station rail vertices “as the crow flies”? In other words, using Pythagoras’
 theorem.
 You will need to get the X and Y’s from the rail_vertex table that relate to the
 stations (in the stations table).
 To help, here’s a snippet of the rail_vertex table:*/
SELECT *
FROM rail_vertex
LIMIT 7;
-- Followed by a snippet of the station table:
SELECT *
FROM station
LIMIT 8;
/* Vertex_id is a relatable field in both tables. This will test your understanding of
 joins/subqueries, aliases, and mathematical functions in SQL. */
SELECT S1.station_name AS station1,
    S2.station_name AS station2,
    SQRT(
        POWER((RV1.x - RV2.x), 2) + POWER((RV1.y - RV2.y), 2)
    ) AS distance
FROM station S1
    JOIN rail_vertex RV1 ON S1.vertex_id = RV1.vertex_id
    JOIN station S2 ON S2.station_name = 'Perth'
    JOIN rail_vertex RV2 ON S2.vertex_id = RV2.vertex_id
WHERE S1.station_name = 'Karrakatta';
/* POINT-IN-RANGE
 Figure 1 illustrates a bounding box (yellow rectangle) around the suburb of
 North Fremantle (green polygon). Its extent is controlled by the maximum and
 minimum x and y coordinates of North Fremantle. Bounding boxes are used all
 the time in spatial queries – e.g., returning all the imagery within a rectangle or
 to clip your data to an area of interest. In our case, let’s assume that users of the
 train station or town planners may want to know things like how many shops
 are within the bounding box around North Fremantle, for example.
 The following code can be used to create a view that will return a bounding
 box for each suburb. I suggest you reverse engineer it to understand the
 machinations, and run it to get an idea of the results. You will need it for the
 next tasks.  */
CREATE VIEW V_SUBURBBOUNDS AS
SELECT S.Suburb Suburb,
    S.ssc_code SCC,
    MIN(V.x_coord) MinX,
    MAX(v.x_coord) MaxX,
    MIN(v.y_coord) MinY,
    MAX(v.y_coord) MaxY
FROM SUBURB_ATTRIBUTE S,
    SUBURB_VERTEX V,
    SUBURB_ARC A
WHERE V.arc_id = A.arc_id
    AND (
        A.left_poly = S.suburb_id
        OR A.right_poly = S.suburb_id
    )
GROUP BY S.Suburb,
    S.ssc_code
ORDER BY S.Suburb;
SELECT *
FROM V_SUBURBBOUNDS
LIMIT 10;
/* Task 2
 Design a single SELECT statement that will find the names of all stations that
 are within (or partially within) the bounding box of any suburb whose name
 starts with any of North, South, West, East, or Central, and display along with
 the suburb(s) they lie within. */
SELECT DISTINCT S.station_name,
    V.Suburb
FROM station S
    JOIN rail_vertex RV ON S.vertex_id = RV.vertex_id
    JOIN V_SUBURBBOUNDS V ON RV.x BETWEEN V.MinX AND V.MaxX
    AND RV.y BETWEEN V.MinY AND V.MaxY
WHERE V.Suburb ~* '^(North|South|West|East|Central)';
/* Task 3
 Design a single SELECT statement that will find the names of all stations whose
 name starts with any of North, South, West, East, or Central and display along
 with the suburb bounding box(es) they lie within. NB: this task is asking for
 STATIONS starting with North, South, West, East or Central, as opposed to task
 1, which asked for SUBURBS starting with those). */
SELECT DISTINCT S.station_name,
    V.Suburb
FROM station S
    JOIN rail_vertex RV ON S.vertex_id = RV.vertex_id
    JOIN V_SUBURBBOUNDS V ON RV.x BETWEEN V.MinX AND V.MaxX
    AND RV.y BETWEEN V.MinY AND V.MaxY
WHERE S.station_name ~* '^(North|South|West|East|Central)';
/* Task 4
 Combine the results from both statements to give you records where both
 station and suburb names start with any of North, South, West, East or
 Central? Prove it by supplying the necessary SQL. If you don’t have any results
 for Task 1 and Task 2, you should still attempt the question for part marks. */
SELECT DISTINCT S.station_name,
    V.Suburb
FROM station S
    JOIN rail_vertex RV ON S.vertex_id = RV.vertex_id
    JOIN V_SUBURBBOUNDS V ON RV.x BETWEEN V.MinX AND V.MaxX
    AND RV.y BETWEEN V.MinY AND V.MaxY
WHERE V.Suburb ~* '^(North|South|West|East|Central)'
    AND S.station_name ~* '^(North|South|West|East|Central)';