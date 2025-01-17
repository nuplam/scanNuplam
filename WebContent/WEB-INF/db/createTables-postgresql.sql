--
--    Mango - Open Source M2M - http://mango.serotoninsoftware.com
--    Copyright (C) 2006-2011 Serotonin Software Technologies Inc.
--    @author Matthew Lohbihler
--    
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
--

-- Make sure that everything get created with utf8 as the charset.
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- System settings
create table systemSettings (
  settingName varchar(32) not null,
  settingValue text,
  primary key (settingName)
) ;


--
-- Users
create table users (
  id serial not null,
  username varchar(40) not null,
  password varchar(30) not null,
  email varchar(255) not null,
  phone varchar(40),
  admin char(1) not null,
  disabled char(1) not null,
  lastLogin bigint,
  selectedWatchList int,
  homeUrl varchar(255),
  receiveAlarmEmails int not null,
  receiveOwnAuditEvents char(1) not null,
  primary key (id)
) ;

create table userComments (
  userId int,
  commentType int not null,
  typeKey int not null,
  ts bigint not null,
  commentText varchar(1024) not null
) ;
alter table userComments add constraint userCommentsFk1 foreign key (userId) references users(id);


--
-- Mailing lists
create table mailingLists (
  id serial not null,
  xid varchar(50) not null,
  name varchar(40) not null,
  primary key (id)
) ;
alter table mailingLists add constraint mailingListsUn1 unique (xid);

create table mailingListInactive (
  mailingListId int not null,
  inactiveInterval int not null
) ;
alter table mailingListInactive add constraint mailingListInactiveFk1 foreign key (mailingListId) 
  references mailingLists(id) on delete cascade;

create table mailingListMembers (
  mailingListId int not null,
  typeId int not null,
  userId int,
  address varchar(255)
) ;
alter table mailingListMembers add constraint mailingListMembersFk1 foreign key (mailingListId) 
  references mailingLists(id) on delete cascade;




--
--
-- Data Sources
--
create table dataSources (
  id serial not null,
  xid varchar(50) not null,
  name varchar(40) not null,
  dataSourceType int not null,
  data bytea not null,
  primary key (id)
) ;
alter table dataSources add constraint dataSourcesUn1 unique (xid);





-- Data source permissions
create table dataSourceUsers (
  dataSourceId int not null,
  userId int not null
) ;
alter table dataSourceUsers add constraint dataSourceUsersFk1 foreign key (dataSourceId) references dataSources(id);
alter table dataSourceUsers add constraint dataSourceUsersFk2 foreign key (userId) references users(id) on delete cascade;

--
--
-- Scripts
--
create table scripts (
  id serial not null,
  userId int not null,
  xid varchar(50) not null,
  name varchar(40) not null,
  script varchar(16384) not null,
  data bytea not null,
  primary key (id)
) ;
alter table scripts add constraint scriptsUn1 unique (xid);
alter table scripts add constraint scriptsFk1 foreign key (userId) references users(id);

--
--
-- FlexProjects
--
create table flexProjects (
  id serial not null,
  name varchar(40) not null,
  description varchar(1024),
  xmlConfig varchar(16384) not null,
  primary key (id)
) ;
--
--
-- Data Points
--
create table dataPoints (
  id serial not null,
  xid varchar(50) not null,
  dataSourceId int not null,
  data bytea not null,
  primary key (id)
) ;
alter table dataPoints add constraint dataPointsUn1 unique (xid);
alter table dataPoints add constraint dataPointsFk1 foreign key (dataSourceId) references dataSources(id);


-- Data point permissions
create table dataPointUsers (
  dataPointId int not null,
  userId int not null,
  permission int not null
) ;
alter table dataPointUsers add constraint dataPointUsersFk1 foreign key (dataPointId) references dataPoints(id);
alter table dataPointUsers add constraint dataPointUsersFk2 foreign key (userId) references users(id) on delete cascade;


--
--
-- Views
--
create table mangoViews (
  id serial not null,
  xid varchar(50) not null,
  name varchar(100) not null,
  background varchar(255),
  userId int not null,
  anonymousAccess int not null,
  data bytea not null,
  primary key (id)
) ;
alter table mangoViews add constraint mangoViewsUn1 unique (xid);
alter table mangoViews add constraint mangoViewsFk1 foreign key (userId) references users(id) on delete cascade;

create table mangoViewUsers (
  mangoViewId int not null,
  userId int not null,
  accessType int not null,
  primary key (mangoViewId, userId)
) ;
alter table mangoViewUsers add constraint mangoViewUsersFk1 foreign key (mangoViewId) references mangoViews(id) on delete cascade;
alter table mangoViewUsers add constraint mangoViewUsersFk2 foreign key (userId) references users(id) on delete cascade;


--
--
-- Point Values (historical data)
--
create table pointValues (
  id bigserial not null,
  dataPointId int not null,
  dataType int not null,
  pointValue double precision,
  ts bigint not null,
  primary key (id)
) ;
alter table pointValues add constraint pointValuesFk1 foreign key (dataPointId) references dataPoints(id) on delete cascade;
create index pointValuesIdx1 on pointValues (ts, dataPointId);
create index pointValuesIdx2 on pointValues (dataPointId, ts);

create table pointValueAnnotations (
  pointValueId bigint not null,
  textPointValueShort varchar(128),
  textPointValueLong text,
  sourceType smallint,
  sourceId int
) ;
alter table pointValueAnnotations add constraint pointValueAnnotationsFk1 foreign key (pointValueId) 
  references pointValues(id) on delete cascade;


--
--
-- Watch list
--
create table watchLists (
  id serial not null,
  xid varchar(50) not null,
  userId int not null,
  name varchar(50),
  primary key (id)
) ;
alter table watchLists add constraint watchListsUn1 unique (xid);
alter table watchLists add constraint watchListsFk1 foreign key (userId) references users(id) on delete cascade;

create table watchListPoints (
  watchListId int not null,
  dataPointId int not null,
  sortOrder int not null
) ;
alter table watchListPoints add constraint watchListPointsFk1 foreign key (watchListId) references watchLists(id) on delete cascade;
alter table watchListPoints add constraint watchListPointsFk2 foreign key (dataPointId) references dataPoints(id);

create table watchListUsers (
  watchListId int not null,
  userId int not null,
  accessType int not null,
  primary key (watchListId, userId)
) ;
alter table watchListUsers add constraint watchListUsersFk1 foreign key (watchListId) references watchLists(id) on delete cascade;
alter table watchListUsers add constraint watchListUsersFk2 foreign key (userId) references users(id) on delete cascade;


--
--
-- Point event detectors
--
create table pointEventDetectors (
  id serial not null,
  xid varchar(50) not null,
  alias varchar(255),
  dataPointId int not null,
  detectorType int not null,
  alarmLevel int not null,
  stateLimit double precision,
  duration int,
  durationType int,
  binaryState char(1),
  multistateState int,
  changeCount int,
  alphanumericState varchar(128),
  weight double precision,
  primary key (id)
) ;
alter table pointEventDetectors add constraint pointEventDetectorsUn1 unique (xid, dataPointId);
alter table pointEventDetectors add constraint pointEventDetectorsFk1 foreign key (dataPointId) 
  references dataPoints(id);


--
--
-- Events
--
create table events (
  id serial not null,
  typeId int not null,
  typeRef1 int not null,
  typeRef2 int not null,
  activeTs bigint not null,
  rtnApplicable char(1) not null,
  rtnTs bigint,
  rtnCause int,
  alarmLevel int not null,
  message text,
  ackTs bigint,
  ackUserId int,
  alternateAckSource int,
  primary key (id)
) ;
alter table events add constraint eventsFk1 foreign key (ackUserId) references users(id);

create table userEvents (
  eventId int not null,
  userId int not null,
  silenced char(1) not null,
  primary key (eventId, userId)
) ;
alter table userEvents add constraint userEventsFk1 foreign key (eventId) references events(id) on delete cascade;
alter table userEvents add constraint userEventsFk2 foreign key (userId) references users(id) on delete cascade;


--
--
-- Event handlers
--
create table eventHandlers (
  id serial not null,
  xid varchar(50) not null,
  alias varchar(255),
  
  -- Event type, see events
  eventTypeId int not null,
  eventTypeRef1 int not null,
  eventTypeRef2 int not null,
  
  data bytea not null,
  primary key (id)
) ;
alter table eventHandlers add constraint eventHandlersUn1 unique (xid);


--
--
-- Scheduled events
--
create table scheduledEvents (
  id serial not null,
  xid varchar(50) not null,
  alias varchar(255),
  alarmLevel int not null,
  scheduleType int not null,
  returnToNormal char(1) not null,
  disabled char(1) not null,
  activeYear int,
  activeMonth int,
  activeDay int,
  activeHour int,
  activeMinute int,
  activeSecond int,
  activeCron varchar(25),
  inactiveYear int,
  inactiveMonth int,
  inactiveDay int,
  inactiveHour int,
  inactiveMinute int,
  inactiveSecond int,
  inactiveCron varchar(25),
  primary key (id)
) ;
alter table scheduledEvents add constraint scheduledEventsUn1 unique (xid);


--
--
-- Point Hierarchy
--
create table pointHierarchy (
  id serial not null,
  parentId int,
  name varchar(100),
  primary key (id)
) ;


--
--
-- Compound events detectors
--
create table compoundEventDetectors (
  id serial not null,
  xid varchar(50) not null,
  name varchar(100),
  alarmLevel int not null,
  returnToNormal char(1) not null,
  disabled char(1) not null,
  conditionText varchar(256) not null,
  primary key (id)
) ;
alter table compoundEventDetectors add constraint compoundEventDetectorsUn1 unique (xid);


--
--
-- Reports
--
create table reports (
  id serial not null,
  userId int not null,
  name varchar(100) not null,
  data bytea not null,
  primary key (id)
) ;
alter table reports add constraint reportsFk1 foreign key (userId) references users(id) on delete cascade;

create table reportInstances (
  id serial not null,
  userId int not null,
  name varchar(100) not null,
  includeEvents int not null,
  includeUserComments char(1) not null,
  reportStartTime bigint not null,
  reportEndTime bigint not null,
  runStartTime bigint,
  runEndTime bigint,
  recordCount int,
  preventPurge char(1),
  primary key (id)
) ;
alter table reportInstances add constraint reportInstancesFk1 foreign key (userId) references users(id) on delete cascade;

create table reportInstancePoints (
  id serial not null,
  reportInstanceId int not null,
  dataSourceName varchar(40) not null,
  pointName varchar(100) not null,
  dataType int not null,
  startValue varchar(4096),
  textRenderer bytea,
  colour varchar(6),
  consolidatedChart char(1),
  primary key (id)
) ;
alter table reportInstancePoints add constraint reportInstancePointsFk1 foreign key (reportInstanceId) 
  references reportInstances(id) on delete cascade;

create table reportInstanceData (
  pointValueId bigint not null,
  reportInstancePointId int not null,
  pointValue double precision,
  ts bigint not null,
  primary key (pointValueId, reportInstancePointId)
) ;
alter table reportInstanceData add constraint reportInstanceDataFk1 foreign key (reportInstancePointId) 
  references reportInstancePoints(id) on delete cascade;

create table reportInstanceDataAnnotations (
  pointValueId bigint not null,
  reportInstancePointId int not null,
  textPointValueShort varchar(128),
  textPointValueLong text,
  sourceValue varchar(128),
  primary key (pointValueId, reportInstancePointId)
) ;
alter table reportInstanceDataAnnotations add constraint reportInstanceDataAnnotationsFk1 
  foreign key (pointValueId, reportInstancePointId) references reportInstanceData(pointValueId, reportInstancePointId) 
  on delete cascade;

create table reportInstanceEvents (
  eventId int not null,
  reportInstanceId int not null,
  typeId int not null,
  typeRef1 int not null,
  typeRef2 int not null,
  activeTs bigint not null,
  rtnApplicable char(1) not null,
  rtnTs bigint,
  rtnCause int,
  alarmLevel int not null,
  message text,
  ackTs bigint,
  ackUsername varchar(40),
  alternateAckSource int,
  primary key (eventId, reportInstanceId)
) ;
alter table reportInstanceEvents add constraint reportInstanceEventsFk1 foreign key (reportInstanceId)
  references reportInstances(id) on delete cascade;

create table reportInstanceUserComments (
  reportInstanceId int not null,
  username varchar(40),
  commentType int not null,
  typeKey int not null,
  ts bigint not null,
  commentText varchar(1024) not null
) ;
alter table reportInstanceUserComments add constraint reportInstanceUserCommentsFk1 foreign key (reportInstanceId)
  references reportInstances(id) on delete cascade;


--
--
-- Publishers
--
create table publishers (
  id serial not null,
  xid varchar(50) not null,
  data bytea not null,
  primary key (id)
) ;
alter table publishers add constraint publishersUn1 unique (xid);


--
--
-- Point links
--
create table pointLinks (
  id serial not null,
  xid varchar(50) not null,
  sourcePointId int not null,
  targetPointId int not null,
  script text,
  eventType int not null,
  disabled char(1) not null,
  primary key (id)
) ;
alter table pointLinks add constraint pointLinksUn1 unique (xid);


--
--
-- Maintenance events
--
create table maintenanceEvents (
  id serial not null,
  xid varchar(50) not null,
  dataSourceId int not null,
  alias varchar(255),
  alarmLevel int not null,
  scheduleType int not null,
  disabled char(1) not null,
  activeYear int,
  activeMonth int,
  activeDay int,
  activeHour int,
  activeMinute int,
  activeSecond int,
  activeCron varchar(25),
  inactiveYear int,
  inactiveMonth int,
  inactiveDay int,
  inactiveHour int,
  inactiveMinute int,
  inactiveSecond int,
  inactiveCron varchar(25),
  primary key (id)
) ;
alter table maintenanceEvents add constraint maintenanceEventsUn1 unique (xid);
alter table maintenanceEvents add constraint maintenanceEventsFk1 foreign key (dataSourceId) references dataSources(id);

CREATE TABLE eventDetectorTemplates (
  id serial NOT NULL,
  name varchar(255) NOT NULL,
  primary key (id)
);

CREATE TABLE templatesDetectors (
  id serial NOT NULL ,
  xid varchar(50) NOT NULL,
  alias varchar(255),
  detectorType int NOT NULL,
  alarmLevel int NOT NULL,
  stateLimit FLOAT,
  duration int,
  durationType int,
  binaryState char(1),
  multistateState int,
  changeCount int,
  alphanumericState varchar(128),
  weight float,
  threshold double,
  eventDetectorTemplateId int NOT NULL,
  primary key (id)
);
ALTER TABLE templatesDetectors ADD CONSTRAINT templatesDetectorsFk1 FOREIGN KEY (eventDetectorTemplateId) REFERENCES eventDetectorTemplates (id);

CREATE TABLE usersProfiles (
  id serial NOT NULL,
  xid varchar(50) not null,
  name varchar(255) NOT NULL,
  primary key (id)
);

-- Data source permissions
create table dataSourceUsersProfiles (
  dataSourceId int not null,
  userProfileId int not null
);
alter table dataSourceUsersProfiles add constraint dataSourceUsersProfilesFk1 foreign key (dataSourceId) references dataSources(id) on delete cascade;
alter table dataSourceUsersProfiles add constraint dataSourceUsersProfilesFk2 foreign key (userProfileId) references usersProfiles(id) on delete cascade;

-- Data point permissions
create table dataPointUsersProfiles (
  dataPointId int not null,
  userProfileId int not null,
  permission int not null
);
alter table dataPointUsersProfiles add constraint dataPointUsersProfilesFk1 foreign key (dataPointId) references dataPoints(id) on delete cascade;
alter table dataPointUsersProfiles add constraint dataPointUsersProfilesFk2 foreign key (userProfileId) references usersProfiles(id) on delete cascade;

-- Data source permissions
create table usersUsersProfiles (
  userProfileId int not null,
  userId int not null
);
alter table usersUsersProfiles add constraint usersUsersProfilesFk1 foreign key (userProfileId) references usersProfiles(id) on delete cascade;
alter table usersUsersProfiles add constraint usersUsersProfilesFk2 foreign key (userId) references users(id) on delete cascade;

-- Watchlist permissions
create table watchListUsersProfiles (
  watchlistId int not null,
  userProfileId int not null,
  permission int not null
);
alter table watchListUsersProfiles add constraint watchListUsersProfilesFk1 foreign key (watchlistId) references watchLists(id) on delete cascade;
alter table watchListUsersProfiles add constraint watchListUsersProfilesFk2 foreign key (userProfileId) references usersProfiles(id) on delete cascade;

-- Watchlist permissions
create table viewUsersProfiles (
  viewId int not null,
  userProfileId int not null,
  permission int not null
);
alter table viewUsersProfiles add constraint viewUsersProfilesFk1 foreign key (viewId) references mangoViews(id) on delete cascade;
alter table viewUsersProfiles add constraint viewUsersProfilesFk2 foreign key (userProfileId) references usersProfiles(id) on delete cascade;