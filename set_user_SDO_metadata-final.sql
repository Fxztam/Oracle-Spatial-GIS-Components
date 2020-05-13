--
-- Delete and Set SDO MetaData of all Feature Tables in the active schema
-- Friedhold Matz : 2020-04-24
--
CREATE OR REPLACE PROCEDURE set_user_SDO_metadata IS
   l_SRID NUMBER(10);
BEGIN
   FOR c IN (select Table_name, Column_name
               from user_tab_columns
               where Data_type = 'SDO_GEOMETRY'
               order by Table_name
            )
   LOOP
      EXECUTE IMMEDIATE 'delete from user_sdo_geom_metadata 
                            where Table_name= '''|| c.Table_name ||''' and
                                  Column_name='''|| c.Column_name||'''';
            
      EXECUTE IMMEDIATE 'select s.'|| c.Column_name ||'.sdo_srid from '||
                            c.Table_name ||' s where rownum<2 '
                         INTO l_SRID;   
                                                                                      
      EXECUTE IMMEDIATE 'insert into user_sdo_geom_metadata
            ( table_name,  column_name,  diminfo,  srid )
              select
                '''||c.Table_name ||''' AS table_name,
                '''||c.Column_name||''' AS column_name,
                mdsys.sdo_dim_array(
                   MDSYS.SDO_DIM_ELEMENT(''X'', minX, maxX, 0.05),
                   MDSYS.SDO_DIM_ELEMENT(''Y'', minY, maxY, 0.05)
                ) as diminfo, 
                :l_SRID as srid
                from (
                select trunc(min(t.x)-1.0) minX,
                       round(max(t.x)+1.0) maxX,
                       trunc(min(t.y)-1.0) minY,
                       round(max(t.y)+1.0) maxY
                from  '||c.Table_name||' b,
                       table(sdo_util.getvertices(b.'||c.Column_name||')) t
                )' USING l_SRID;
   END LOOP;
END set_user_SDO_metadata;
