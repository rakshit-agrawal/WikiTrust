DROP TABLE text_split_version;
DROP TABLE feedback;
DROP TABLE edit_lists;
DROP TABLE trust_user_rep;
DROP TABLE user_rep_history;
DROP TABLE colored_markup;
DROP TABLE dead_page_chunks;
DROP TABLE chunk_text;
DROP TABLE chunk_trust;
DROP TABLE chunk_origin;
DROP TABLE dead_page_chunk_map;
DROP TABLE quality_info;

-- quality info?
CREATE TABLE quality_info (
        rev_id                  int PRIMARY KEY,
        n_edit_judges           int NOT NULL,
        total_edit_quality      float NOT NULL,
        min_edit_quality        float NOT NULL,
        n_text_judges           int NOT NULL,
        new_text                int NOT NULL,
        persistent_text         int NOT NULL
);
GRANT ALL ON quality_info TO wikiuser;

-- maps page_id to text of the most recently added revision
CREATE TABLE text_split_version (
        page_id                 int PRIMARY KEY,
        current_rev_text        text NOT NULL,
        updatedon               timestamp DEFAULT now()
);

GRANT ALL ON text_split_version TO wikiuser;

-- a place to store feedback
CREATE TABLE feedback (
  revid1        int NOT NULL, 
  userid1       int NOT NULL,
  revid2        int NOT NULL, 
  userid2       int NOT NULL, 
  timestamp     float NOT NULL, 
  q             float NOT NULL,
  voided        bool NOT NULL,
  PRIMARY KEY (revid1, userid1, revid2, userid2, timestamp)
);

CREATE INDEX feedback_idx on feedback(revid1);
GRANT ALL ON feedback TO wikiuser;

-- now, a place to store edit lists
CREATE TABLE edit_lists (
        from_revision   int , 
        to_revision     int,
        edit_type       enum ('Ins','Del','Mov'),
        version         text NOT NULL,
        val1            int NOT NULL,
        val2            int NOT NULL,
        val3            int,
        updatedon       timestamp DEFAULT now(),
        PRIMARY KEY (from_revision, to_revision, edit_type)
);

CREATE INDEX edit_lists_idx ON edit_lists (from_revision, to_revision);
GRANT ALL ON edit_lists TO wikiuser;

-- Reputation of a user
-- first, a table with all known user names and ids
CREATE TABLE trust_user_rep(
    user_id     int PRIMARY KEY   ,
    user_text   varchar(255)     ,
    user_rep    float DEFAULT 0.0,
    addedon     timestamp NOT NULL DEFAULT now()
);
GRANT ALL ON trust_user_rep TO wikiuser;

-- also have historical records of user're reputation
CREATE TABLE user_rep_history(
        user_id     int NOT NULL,
        rep_before  float NOT NULL,
        rep_after   float NOT NULL,
        change_time float NOT NULL,
        primary key (user_id, change_time)
);
GRANT ALL ON user_rep_history TO wikiuser;

-- place a store colored markup
CREATE TABLE colored_markup (
        revision_id     int PRIMARY KEY,
        revision_text   text NOT NULL
);
GRANT ALL ON colored_markup TO wikiuser;

CREATE TABLE chunk_text (
        text_id serial PRIMARY KEY,
        chunk_text text NOT NULL
);
GRANT ALL ON chunk_text TO wikiuser;
/* CREATE INDEX chunk_text_idx ON chunk_text(chunk_text, 1000); */

CREATE TABLE chunk_trust (
        trust_id serial PRIMARY KEY,
        chunk_trust float  NOT NULL
);
GRANT ALL ON chunk_trust TO wikiuser;

CREATE TABLE chunk_origin (
        origin_id serial PRIMARY KEY,
        chunk_origin int  NOT NULL
);
GRANT ALL ON chunk_origin TO wikiuser;

CREATE TABLE dead_page_chunks (
        chunk_id   serial PRIMARY KEY,
        timestamp  float NOT NULL,
        page_id    int NOT NULL,
        n_del_revs int NOT NULL,
        n_chunks   int NOT NULL,
        addedon    timestamp NOT NULL DEFAULT now()
);
CREATE INDEX dead_page_chunks_page_idx on dead_page_chunks (page_id);
GRANT ALL ON dead_page_chunks TO wikiuser;

CREATE TABLE dead_page_chunk_map (
        chunk_id int REFERENCES dead_page_chunks(chunk_id) ON DELETE CASCADE ON
               UPDATE CASCADE,
        text_id int REFERENCES chunk_text(text_id) ON DELETE CASCADE ON 
                UPDATE CASCADE,
        trust_id int REFERENCES chunk_trust(trust_id)  ON DELETE CASCADE ON 
                UPDATE CASCADE,
        origin_id int REFERENCES chunk_origin(origin_id)  ON DELETE CASCADE ON 
               UPDATE CASCADE,
        chunk_posit int NOT NULL,
        PRIMARY KEY (chunk_id, text_id, trust_id, origin_id)
);

CREATE INDEX dead_chunk_map_posit_id ON dead_page_chunk_map (chunk_posit);
GRANT ALL ON dead_page_chunk_map TO wikiuser;



