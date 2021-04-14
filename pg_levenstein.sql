
/*
 * Calculates the Levenshtein editing distance
 * 
 */

--------------------------------------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS levenstein CASCADE;
CREATE FUNCTION levenstein (fst TEXT, snd TEXT) RETURNS int STRICT AS $$
	declare 
		flen INT := length(fst);
		slen INT := length(snd);
		D INT[][] := array_fill(0, array[flen, slen]);
		cst INT; upp INT; lef INT; cor INT;
    BEGIN
        for i in 1 .. flen loop 
        	for j in 1 .. slen loop
        		if lower(substring(fst, i, 1)) = lower(substring(snd, j, 1)) 
        			then cst := 0;
        			else cst := 1;
        		end if;
        		upp := coalesce(D[i-1][j], i);
        		lef := coalesce(D[i][j-1], j);
        		cor := coalesce(D[i-1][j-1], 0);
        		D[i][j] := least(upp + 1, lef + 1, cor + cst);
        	end loop;
	    END loop;
		RETURN D[flen][slen];		
    END;
$$ LANGUAGE plpgsql; 


-- Test
with
tmp as (select 'EDITING' as fst, 'DISTANCE' as snd
		union
		select 'Строка' as fst, 'собака' as snd
		union 
		select 'НСЗУ' as fst, 'МОЗ' as snd
	)
select fst, snd, levenstein(fst, snd)
from tmp



