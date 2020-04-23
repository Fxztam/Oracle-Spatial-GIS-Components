    ----------------------------------------------------------------------------------------
    --Copyright © 2007 Open Geospatial Consortium, Inc. All Rights Reserved. OGC 06-104r4 
    --Copyright © 2007 Open Geospatial Consortium, Inc. All Rights Reserved. xcvii 
	-- .................................................................................. --
	-- Adapted for Oracle Spatial OracleATP Cloud : Friedhold Matz 21.04.2020 .
    -- SDO : Oracle Spatial Data Object  (Oracle specific geometry data type)
    ----------------------------------------------------------------------------------------

    -- 1.) BO - DROP objects and delete metadata --	
    BEGIN
      EXECUTE IMMEDIATE '
            CREATE or REPLACE PROCEDURE drop_object (p_type VARCHAR2, p_name VARCHAR2) IS
                BEGIN
                    EXECUTE IMMEDIATE ''drop ''||p_type||''  ''||p_name;
                EXCEPTION WHEN OTHERS THEN NULL;
            END drop_object;
        ';
       EXCEPTION WHEN OTHERS THEN NULL;
    END;
/
	BEGIN
        FOR ct in (select Table_name tabname 
						  from user_tables) 
        LOOP
            BEGIN
			    dbms_output.put_line(ct.tabname);
                drop_object('table', upper(ct.tabname));
			EXCEPTION WHEN OTHERS THEN NULL;
            END;
        END LOOP;		
    END drop_tables;
/
	BEGIN
		FOR cc in (select Table_name tabname, Column_name colname, Data_type dtype
						from user_tab_columns uc where uc.Data_type='SDO_GEOMETRY' ) 
        LOOP
			BEGIN
				drop_object('index', upper('IXSDO_'||cc.tabname||'_'||cc.colname));
				delete from user_sdo_geom_metadata u 
					where u.table_name=cc.tabname and u.column_name=cc.colname;
            EXCEPTION WHEN OTHERS THEN NULL;
            END;
        END LOOP;
    END drop_sdo_indexes_delete_metadata;
/
    -- EO - DROP objects and delete metadata --	
    
    -- 2.) BO - Create tables --
    CREATE TABLE lakes ( 
        fid             INTEGER NOT NULL PRIMARY KEY, 
        name            VARCHAR2(64), 
        shore           SDO_GEOMETRY
    ); 
	
    -- Road Segments : LINESTRING
    CREATE TABLE road_segments ( 
        fid             INTEGER NOT NULL PRIMARY KEY, 
        name            VARCHAR2(64), 
        aliases         VARCHAR2(64), 
        num_lanes       INTEGER, 
        centerline      SDO_GEOMETRY
    ); 
	
    -- Divided Routes : MULTILINESTRING
    CREATE TABLE divided_routes ( 
        fid             INTEGER NOT NULL PRIMARY KEY, 
        name            VARCHAR2(64), 
        num_lanes       INTEGER, 
        centerlines     SDO_GEOMETRY
    ); 
	
    -- Forests 
    CREATE TABLE forests ( 
        fid             INTEGER NOT NULL PRIMARY KEY, 
        name            VARCHAR2(64), 
        boundary        SDO_GEOMETRY
    ); 
	
    -- Bridges 
    CREATE TABLE bridges ( 
        fid             INTEGER NOT NULL PRIMARY KEY, 
        name            VARCHAR2(64), 
        position        SDO_GEOMETRY
    );
	
    -- Streams 
    CREATE TABLE streams ( 
        fid             INTEGER NOT NULL PRIMARY KEY,  
        name            VARCHAR2(64), 
        centerline      SDO_GEOMETRY
    );
	
    -- Buildings 
    CREATE TABLE buildings ( 
        fid             INTEGER NOT NULL PRIMARY KEY, 
        address         VARCHAR2(64), 
        position        SDO_GEOMETRY, 
        footprint       SDO_GEOMETRY
    ); 
	
    -- Ponds 
    CREATE TABLE ponds ( 
        fid             INTEGER NOT NULL PRIMARY KEY, 
        name            VARCHAR2(64), 
        type            VARCHAR2(64), 
        shores          SDO_GEOMETRY
    ); 
	
    -- Named Places 
    CREATE TABLE named_places ( 
        fid             INTEGER NOT NULL PRIMARY KEY, 
        name            VARCHAR2(64), 
        boundary        SDO_GEOMETRY
    ); 
	
    -- Map Neatline
    CREATE TABLE map_neatlines ( 
        fid             INTEGER NOT NULL PRIMARY KEY, 
        neatline        SDO_GEOMETRY
    ); 

----------------------------------------------------------------------------------------------------------------------
-- 3.3.2 Geometry types and functions schema data loading  -----------------------------------------------------------
-- Spatial Reference System ------------------------------------------------------------------------------------------
-- INSERT INTO spatial_ref_sys VALUES (101, 'POSC', 32214, 'PROJCS["UTM_ZONE_14N",  
-- GEOGCS["World Geodetic System 72", DATUM["WGS_72", ELLIPSOID["NWL_10D", 6378135, 298.26]], PRIMEM["Greenwich", 0],  
--         UNIT["Meter", 1.0]], PROJECTION["Transverse_Mercator"], 
--         PARAMETER["False_Easting", 500000.0], 
--         PARAMETER["False_Northing", 0.0], 
--         PARAMETER["Central_Meridian", -99.0], 
--         PARAMETER["Scale_Factor", 0.9996], 
--         PARAMETER["Latitude_of_origin", 0.0], UNIT["Meter", 1.0]]'); 
----------------------------------------------------------------------------------------------------------------------
SET DEFINE OFF;

-- 3.) BO - Insert geo data --

-- Lakes 
Insert into OGC_DEMO.LAKES (FID,NAME,SHORE) values ('101','BLUE LAKE',MDSYS.SDO_GEOMETRY(2003, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 1, 11, 2003, 1), MDSYS.SDO_ORDINATE_ARRAY(52, 18,  48, 6,  73, 9,  66, 23,  52, 18,   59, 18, 67, 18, 67, 13, 59, 13, 59, 18)));


-- Road segments 
Insert into OGC_DEMO.ROAD_SEGMENTS (FID,NAME,ALIASES,NUM_LANES,CENTERLINE) values ('102','Route 5',null,'2',MDSYS.SDO_GEOMETRY(2002, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 2, 1), MDSYS.SDO_ORDINATE_ARRAY(0, 18, 10, 21, 16, 23, 28, 26, 44, 31)));
Insert into OGC_DEMO.ROAD_SEGMENTS (FID,NAME,ALIASES,NUM_LANES,CENTERLINE) values ('103','Route 5','Main Street','4',MDSYS.SDO_GEOMETRY(2002, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 2, 1), MDSYS.SDO_ORDINATE_ARRAY(44, 31, 56, 34, 70, 38)));
Insert into OGC_DEMO.ROAD_SEGMENTS (FID,NAME,ALIASES,NUM_LANES,CENTERLINE) values ('104','Route 5',null,'2',MDSYS.SDO_GEOMETRY(2002, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 2, 1), MDSYS.SDO_ORDINATE_ARRAY(70, 38, 72, 48)));
Insert into OGC_DEMO.ROAD_SEGMENTS (FID,NAME,ALIASES,NUM_LANES,CENTERLINE) values ('105','Main Street',null,'4',MDSYS.SDO_GEOMETRY(2002, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 2, 1), MDSYS.SDO_ORDINATE_ARRAY(70, 38, 84, 42)));
Insert into OGC_DEMO.ROAD_SEGMENTS (FID,NAME,ALIASES,NUM_LANES,CENTERLINE) values ('106','Dirt Road by Green Forest',null,'1',MDSYS.SDO_GEOMETRY(2002, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 2, 1), MDSYS.SDO_ORDINATE_ARRAY(28, 26, 28, 0)));

-- DividedRoutes 
Insert into OGC_DEMO.DIVIDED_ROUTES (FID,NAME,NUM_LANES,CENTERLINES) values ('119','Route 75','4',MDSYS.SDO_GEOMETRY(2006, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 2, 1, 7, 2, 1), MDSYS.SDO_ORDINATE_ARRAY(10, 48, 10, 21, 10, 0, 16, 0, 16, 23, 16, 48)));

-- Forests 
-- INSERT INTO forests VALUES(109, 'Green Forest',         SDO_GEOMETRY( 'MULTIPOLYGON(((28 26,28 0,84 0,84 42,28 26), (52 18,66 23,73 9,48 6,52 18)),((59 18,67 18,67 13,59 13,59 18)))' , 32214 )); 
-- Insert into OGC_DEMO.FORESTS (FID,NAME,BOUNDARY) values ('109','Green Forest',MDSYS.SDO_GEOMETRY(2007, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 1, 11, 2003, 1, 21, 1003, 1), MDSYS.SDO_ORDINATE_ARRAY(28, 26, 28, 0, 84, 0, 84, 42, 28, 26,  52, 18, 66, 23, 73, 9, 48, 6, 52, 18,    59, 18, 67, 18, 67, 13, 59, 13, 59, 18)));
-- Changed 1 Polygon ! --
Insert into OGC_DEMO.FORESTS (FID,NAME,BOUNDARY) values ('109','Green Forest',MDSYS.SDO_GEOMETRY(2007, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 1, 11, 2003, 1, 21, 1003, 1), MDSYS.SDO_ORDINATE_ARRAY(28, 26, 28, 0, 84, 0, 84, 42, 28, 26,     52, 18, 48, 6, 73, 9, 66, 23, 52, 18,    59, 18, 59, 13, 67, 13, 67, 18, 59, 18)));

 -- SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(BOUNDARY,0.005)
 --------------------------------------------------------------------------------
 --- ??? 

-- Bridges 
Insert into OGC_DEMO.BRIDGES (FID,NAME,POSITION) values ('110','Cam Bridge',MDSYS.SDO_GEOMETRY(2001, 32214, MDSYS.SDO_POINT_TYPE(44, 31, NULL), NULL, NULL));

-- Streams 
Insert into OGC_DEMO.STREAMS (FID,NAME,CENTERLINE) values ('111','Cam Stream',MDSYS.SDO_GEOMETRY(2002, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 2, 1), MDSYS.SDO_ORDINATE_ARRAY(38, 48, 44, 41, 41, 36, 44, 31, 52, 18)));
Insert into OGC_DEMO.STREAMS (FID,NAME,CENTERLINE) values ('112',null,MDSYS.SDO_GEOMETRY(2002, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 2, 1), MDSYS.SDO_ORDINATE_ARRAY(76, 0, 78, 4, 73, 9)));


-- Buildings 
Insert into OGC_DEMO.BUILDINGS (FID,ADDRESS,POSITION,FOOTPRINT) values ('113','123 Main Street',MDSYS.SDO_GEOMETRY(2001, 32214, MDSYS.SDO_POINT_TYPE(52, 30, NULL), NULL, NULL),MDSYS.SDO_GEOMETRY(2003, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 1), MDSYS.SDO_ORDINATE_ARRAY(50, 31,  50, 29, 54, 29, 54, 31, 50, 31)));
Insert into OGC_DEMO.BUILDINGS (FID,ADDRESS,POSITION,FOOTPRINT) values ('114','215 Main Street',MDSYS.SDO_GEOMETRY(2001, 32214, MDSYS.SDO_POINT_TYPE(64, 33, NULL), NULL, NULL),MDSYS.SDO_GEOMETRY(2003, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 1), MDSYS.SDO_ORDINATE_ARRAY(66, 34, 62, 34, 62, 32, 66, 32, 66, 34)));

-- Ponds 
Insert into OGC_DEMO.PONDS (FID,NAME,TYPE,SHORES) values ('120',null,'Stock Pond',MDSYS.SDO_GEOMETRY(2007, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 1, 9, 1003, 1), MDSYS.SDO_ORDINATE_ARRAY(24, 44, 22, 42, 24, 40, 24, 44, 26, 44, 26, 40, 28, 42, 26, 44)));

-- Named Places 
Insert into OGC_DEMO.NAMED_PLACES (FID,NAME,BOUNDARY) values ('117','Ashton',MDSYS.SDO_GEOMETRY(2003, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 1), MDSYS.SDO_ORDINATE_ARRAY(62, 48,  56, 34,  56, 30,  84, 30,  84, 48, 62, 48)));
Insert into OGC_DEMO.NAMED_PLACES (FID,NAME,BOUNDARY) values ('118','Goose Island',MDSYS.SDO_GEOMETRY(2003, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 1), MDSYS.SDO_ORDINATE_ARRAY(67, 13, 67, 18, 59, 18, 59, 13, 67, 13)));

-- Map Neatlines 
Insert into OGC_DEMO.MAP_NEATLINES (FID,NEATLINE) values ('115',MDSYS.SDO_GEOMETRY(2003, 32214, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 1), MDSYS.SDO_ORDINATE_ARRAY(0, 0,  84, 0, 84, 48, 0, 48, 0, 0)));

-- BO - Insert geo data --

COMMIT;

-- 4.) Verifying SDOs : 'TRUE' ---
select sdo_geom.validate_geometry_with_context(SHORE, 0.005) from lakes;
select sdo_geom.validate_geometry_with_context(CENTERLINE, 005) from road_segments;
select sdo_geom.validate_geometry_with_context(CENTERLINE, 005) from road_segments;
select sdo_geom.validate_geometry_with_context(CENTERLINES, 0.005) from divided_routes;
select sdo_geom.validate_geometry_with_context(BOUNDARY, 0.005) from forests;
select sdo_geom.validate_geometry_with_context(POSITION, 0.005) from bridges;
select sdo_geom.validate_geometry_with_context(CENTERLINE, 0.005) from streams;
select sdo_geom.validate_geometry_with_context(FOOTPRINT, 0.005) from buildings;
select sdo_geom.validate_geometry_with_context(SHORES, 0.005) from ponds;
select sdo_geom.validate_geometry_with_context(BOUNDARY, 0.005) from named_places;
select sdo_geom.validate_geometry_with_context(NEATLINE, 0.005) from map_neatlines;

-- 5.) Set SDO metadata
BEGIN
    FOR  c IN   (select Table_name, Column_name 
                    from user_tab_columns  
                    where Data_type like 'SDO_GEOMETRY'
                    order by Table_name
                )
    LOOP
        dbms_output.put_line(c.Table_name);
        EXECUTE IMMEDIATE '
                insert into user_sdo_geom_metadata
                ( table_name,  column_name,  diminfo,  srid )
                    select
                    '''||c.Table_name||''' AS table_name,
                    '''||c.Column_name||''' AS column_name,
                    mdsys.sdo_dim_array( 
                            MDSYS.SDO_DIM_ELEMENT(''X'', minX, maxX, 0.05), 
                            MDSYS.SDO_DIM_ELEMENT(''Y'', minY, maxY, 0.05)
                    ) as diminfo,
                    32214  as srid 
                    from ( 
                    select 	trunc(min(t.x)-1.0) minX, 
                            round(max(t.x)+1.0) maxX,
                            trunc(min(t.y)-1.0) minY, 
                            round(max(t.y)+1.0) maxY
                        from  '||c.Table_name||' b, 
                            table(sdo_util.getvertices(b.'||c.Column_name||')) t
                )';
    END LOOP;
END set_SDO_meta_data;

-- 6.) Create SDO Indexes
BEGIN
    FOR  c IN   (select Table_name, Column_name 
                    from user_tab_columns  
                    where Data_type like 'SDO_GEOMETRY'
                    order by Table_name
                )
    LOOP
        --execute immediate 'drop index ' || tc.table_name || '_'; 
        EXECUTE IMMEDIATE 'Create Index '
            || 'IXSDO_'
            || c.table_name 
            || '_'
            || c.column_name
            || ' on '
            || c.table_name 
            || '(' || c.column_name
            || ') indextype is mdsys.spatial_index';
    END LOOP;
END create_SDO_indexes;

-- FINE. --
