## Validation of all Feature Table SDO_GEOMETRIES in the active schema

```sql
--
-- Validation of all Feature Table SDO geometries in the active schema
-- Result: select * from geom_erresults; - only geometry errors 
-- Friedhold Matz : 2020-04-27
--
CREATE OR REPLACE PROCEDURE validate_SDO_geometries IS
BEGIN
   EXECUTE IMMEDIATE  'BEGIN  
                            EXECUTE IMMEDIATE ''drop table geom_erresults'';
                       EXCEPTION WHEN OTHERS THEN NULL;
                       END;';

   EXECUTE IMMEDIATE   'create table geom_erresults ('
                        || 'tabname VARCHAR2(64), colname VARCHAR2(64), sdo_rowid ROWID, '
                        || 'geometry SDO_GEOMETRY, result VARCHAR2(1024)'
                        || ')';   

   FOR c IN (select Table_name, Column_name
                    from user_tab_columns
                    where Data_type like 'SDO_GEOMETRY'
                    order by Table_name
            )
   LOOP
       BEGIN
          EXECUTE IMMEDIATE 'insert into geom_erresults (tabname, colname, sdo_rowid, geometry, result)'
                            || ' select '''|| c.Table_name || ''', '''|| c.Column_name || ''', '
                            || ' rowid,' || c.Column_name ||', '
                            || ' sdo_geom.validate_geometry_with_context('
                            ||   c.Column_name || ', 0.005) result' 
                            || ' from '|| c.Table_name 
                            || ' where sdo_geom.validate_geometry_with_context('
                            ||   c.Column_name || ', 0.005) != ''TRUE''';
                                                                          
       EXCEPTION WHEN OTHERS THEN
          RAISE;
       END validate;
   END LOOP;
END validate_SDO_geometries;
```

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Results e.g. :
--------------

SQL> select * from geom_erresults;

TABNAME      COLNAME           SDO_ROWID              GEOMETRY    RESULT
------------ ----------------- ---------------------- ----------- ---------------------
FORESTS      BOUNDARY          AAAVnHAAAAAC2aEAAA     <Object>    13367 [Element <1>]
FORESTS_84   GEOMETRY          AAAV/aAAAAAC2vcAAA     <Object>    13367 [Element <1>]
