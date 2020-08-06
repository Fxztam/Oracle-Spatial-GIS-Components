--
-- Drop and Create SDO Index of all Feature Tables in the active schema
-- Friedhold Matz : 2020-04-26
--       Modified : 2020-08.06 : indextype to mdsys.spatial_index_V2
--
CREATE OR REPLACE PROCEDURE create_user_SDO_INDEX IS
BEGIN
    FOR  c IN   (select Table_name, Column_name
                    from user_tab_columns
                    where Data_type like 'SDO_GEOMETRY'
                    order by Table_name
                )
    LOOP
        FOR ix in (select Index_name from user_sdo_index_info 
                        where Table_name=c.Table_name 
                  ) 
        LOOP
           BEGIN
              EXECUTE IMMEDIATE 'drop index '||ix.Index_name;
           EXCEPTION WHEN OTHERS THEN NULL;
           END;
        END LOOP;         
        BEGIN
          EXECUTE IMMEDIATE 'Create Index '
              || 'IXSDO_'
              || c.Table_name
              || '_'
              || c.Column_name
              || ' on '
              || c.Table_name
              || '(' || c.Column_name
              || ') indextype is mdsys.spatial_index_V2';
        EXCEPTION WHEN OTHERS THEN
           dbms_output.put_line(sqlerrm||'/'||c.Table_name);
           RAISE;
        END create_SDO_index;       
    END LOOP;
END create_user_SDO_INDEX;
/
