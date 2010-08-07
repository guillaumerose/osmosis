-- Database script for the simple PostgreSQL schema.  This script moves all tags into hstore columns.

-- Create functions for building hstore data.
CREATE OR REPLACE FUNCTION build_node_tags() RETURNS void AS $$
DECLARE
	previousId nodes.id%TYPE;
	currentId nodes.id%TYPE;
	result hstore;
	tagRow node_tags%ROWTYPE;
BEGIN
	SET enable_seqscan = false;
	SET enable_mergejoin = false;
	SET enable_hashjoin = false;
	
	FOR tagRow IN SELECT * FROM node_tags ORDER BY node_id LOOP
		currentId := tagRow.node_id;
		
		IF currentId <> previousId THEN
			IF previousId IS NOT NULL THEN
				IF result IS NOT NULL THEN
					UPDATE nodes SET tags = result WHERE id = previousId;
					IF ((currentId / 100000) <> (previousId / 100000)) THEN
						RAISE INFO 'node id: %', previousId;
					END IF;
					result := NULL;
				END IF;
			END IF;
		END IF;
		
		IF result IS NULL THEN
			result := tagRow.k => tagRow.v;
		ELSE
			result := result || (tagRow.k => tagRow.v);
		END IF;
		
		previousId := currentId;
	END LOOP;
	
	IF previousId IS NOT NULL THEN
		IF result IS NOT NULL THEN
			UPDATE nodes SET tags = result WHERE id = previousId;
			result := NULL;
		END IF;
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION build_way_tags() RETURNS void AS $$
DECLARE
	previousId ways.id%TYPE;
	currentId ways.id%TYPE;
	result hstore;
	tagRow way_tags%ROWTYPE;
BEGIN
	SET enable_seqscan = false;
	SET enable_mergejoin = false;
	SET enable_hashjoin = false;
	
	FOR tagRow IN SELECT * FROM way_tags ORDER BY way_id LOOP
		currentId := tagRow.way_id;
		
		IF currentId <> previousId THEN
			IF previousId IS NOT NULL THEN
				IF result IS NOT NULL THEN
					UPDATE ways SET tags = result WHERE id = previousId;
					IF ((currentId / 100000) <> (previousId / 100000)) THEN
						RAISE INFO 'way id: %', previousId;
					END IF;
					result := NULL;
				END IF;
			END IF;
		END IF;
		
		IF result IS NULL THEN
			result := tagRow.k => tagRow.v;
		ELSE
			result := result || (tagRow.k => tagRow.v);
		END IF;
		
		previousId := currentId;
	END LOOP;
	
	IF previousId IS NOT NULL THEN
		IF result IS NOT NULL THEN
			UPDATE ways SET tags = result WHERE id = previousId;
			result := NULL;
		END IF;
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION build_relation_tags() RETURNS void AS $$
DECLARE
	previousId relations.id%TYPE;
	currentId relations.id%TYPE;
	result hstore;
	tagRow relation_tags%ROWTYPE;
BEGIN
	SET enable_seqscan = false;
	SET enable_mergejoin = false;
	SET enable_hashjoin = false;
	
	FOR tagRow IN SELECT * FROM relation_tags ORDER BY relation_id LOOP
		currentId := tagRow.relation_id;
		
		IF currentId <> previousId THEN
			IF previousId IS NOT NULL THEN
				IF result IS NOT NULL THEN
					UPDATE relations SET tags = result WHERE id = previousId;
					IF ((currentId / 100000) <> (previousId / 100000)) THEN
						RAISE INFO 'relation id: %', previousId;
					END IF;
					result := NULL;
				END IF;
			END IF;
		END IF;
		
		IF result IS NULL THEN
			result := tagRow.k => tagRow.v;
		ELSE
			result := result || (tagRow.k => tagRow.v);
		END IF;
		
		previousId := currentId;
	END LOOP;
	
	IF previousId IS NOT NULL THEN
		IF result IS NOT NULL THEN
			UPDATE relations SET tags = result WHERE id = previousId;
			result := NULL;
		END IF;
	END IF;
END;
$$ LANGUAGE plpgsql;

-- Add hstore columns to entity tables.
ALTER TABLE nodes ADD COLUMN tags hstore;
ALTER TABLE ways ADD COLUMN tags hstore;
ALTER TABLE relations ADD COLUMN tags hstore;

-- Populate the hstore columns.
SELECT build_node_tags();
SELECT build_way_tags();
SELECT build_relation_tags();

-- Remove the functions.
DROP FUNCTION build_node_tags();
DROP FUNCTION build_way_tags();
DROP FUNCTION build_relation_tags();

-- Update the schema version.
UPDATE schema_info SET version = 6;