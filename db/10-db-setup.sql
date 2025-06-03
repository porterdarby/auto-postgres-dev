CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY,
    name VARCHAR
);

INSERT INTO users (id, name) VALUES
    (1, 'Alex'),
    (2, 'Blake'),
    (3, 'Chris'),
    (4, 'Dan')
ON CONFLICT (id)
DO UPDATE
SET
    id=EXCLUDED.id,
    name=EXCLUDED.name
;

