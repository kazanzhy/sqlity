
/*
 * Calculates the Levenshtein or Damerau-Levenshtein editing distance
 * if third parameter TRUE then works Damerau-Levenshtein
 */

--------------------------------------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS levenshtein CASCADE;
CREATE FUNCTION levenshtein (TEXT, text, damerau bool default FALSE) RETURNS int STRICT AS $$
	declare 
		fst text := lower($1);
		snd text := lower($2);
		flen INT := length(fst);
		slen INT := length(snd);
		D INT[][] := array_fill(0, array[flen, slen]);
		cst INT; del INT; ins INT; sub INT;
    BEGIN
        for i in 1 .. flen loop 
        	for j in 1 .. slen loop
        		cst = (substring(fst,i,1) <> substring(snd,j,1))::int
        		del := coalesce(D[i-1][j], i) + 1; -- deletion
        		ins := coalesce(D[i][j-1], j) + 1; -- insertion
        		sub := coalesce(D[i-1][j-1], 0) + cst; -- substitution
        		D[i][j] := least(del, ins, sub);
        		if damerau and i > 2 and j > 2 and substring(fst,i,1) = substring(snd,j-1,1) and substring(fst,i-1,1) = substring(snd,j,1) then
					D[i][j] := least(D[i][j], D[i-2][j-2] + 1);  -- transposition
        		end if;
        	end loop;
	    END loop;
		RETURN D[flen][slen];		
    END;
$$ LANGUAGE plpgsql;
--------------------------------------------------------------------------------------------------------------------------------
                

-- Test
with
tmp as (select 'EDITING' as fst, 'DISTANCE' as snd
		union
		select 'Строка' as fst, 'собака' as snd
		union 
		select 'НСЗУ' as fst, 'НЗСУ' as snd
	)
select fst, snd, levenshtein(fst, snd), levenshtein(fst, snd, true)
from tmp



