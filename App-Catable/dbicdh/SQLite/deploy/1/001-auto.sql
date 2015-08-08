--
-- Created by SQL::Translator::Producer::SQLite
-- Created on Wed Jul 28 00:29:16 2010
--

;
BEGIN TRANSACTION;
--
-- Table: account
--
CREATE TABLE account (
  id INTEGER PRIMARY KEY NOT NULL,
  url varchar(1024),
  username varchar(50),
  password char(40),
  homepage varchar(1024),
  real_name varchar(100),
  nickname varchar(100),
  age int(3),
  gender char(1),
  last_logon_ts datetime NOT NULL,
  ctime datetime NOT NULL,
  mtime datetime NOT NULL
);
CREATE UNIQUE INDEX account_url ON account (url);
--
-- Table: tag
--
CREATE TABLE tag (
  id INTEGER PRIMARY KEY NOT NULL,
  label varchar(80) NOT NULL
);
CREATE UNIQUE INDEX tag_label ON tag (label);
--
-- Table: blog
--
CREATE TABLE blog (
  id INTEGER PRIMARY KEY NOT NULL,
  owner_id bigint NOT NULL,
  url varchar(32) NOT NULL,
  title varchar(255) NOT NULL,
  theme varchar(1024) NOT NULL,
  ctime datetime NOT NULL,
  mtime datetime NOT NULL
);
CREATE INDEX blog_idx_owner_id ON blog (owner_id);
CREATE UNIQUE INDEX blog_url ON blog (url);
--
-- Table: entry
--
CREATE TABLE entry (
  id INTEGER PRIMARY KEY NOT NULL,
  title varchar(400) NOT NULL,
  body blob,
  can_be_published bool NOT NULL,
  pubdate datetime NOT NULL,
  update_date datetime NOT NULL,
  parent_id bigint,
  author_id bigint
);
CREATE INDEX entry_idx_author_id ON entry (author_id);
CREATE INDEX entry_idx_parent_id ON entry (parent_id);
--
-- Table: blog_entry
--
CREATE TABLE blog_entry (
  blog_id bigint NOT NULL,
  entry_id bigint NOT NULL,
  PRIMARY KEY (blog_id, entry_id)
);
CREATE INDEX blog_entry_idx_blog_id ON blog_entry (blog_id);
CREATE INDEX blog_entry_idx_entry_id ON blog_entry (entry_id);
--
-- Table: post_tag_assoc
--
CREATE TABLE post_tag_assoc (
  post_id bigint NOT NULL,
  tag_id bigint NOT NULL,
  PRIMARY KEY (post_id, tag_id)
);
CREATE INDEX post_tag_assoc_idx_post_id ON post_tag_assoc (post_id);
CREATE INDEX post_tag_assoc_idx_tag_id ON post_tag_assoc (tag_id);
COMMIT
