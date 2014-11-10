function e = primarykeys(d,c,s,t)
%PRIMARYKEYS Get primary key information for database table or schema.
%   E = PRIMARYKEYS(D,C,S,T) returns the primary key information for a given
%   database metadata object D, catalog C, schema S, and table T.
%
%   E = PRIMARYKEYS(D,C,S) returns the primary key information for all tables
%   associated with the database metadata object D, catalog C, and schema S.
%
%   See also GET, EXPORTEDKEYS, IMPORTEDKEYS.

%   Author(s): C.F.Garvin, 08-06-98
%   Copyright 1984-2006 The MathWorks, Inc.

%Create com.mathworks.toolbox.database.databaseDMD instance handle
a = com.mathworks.toolbox.database.databaseDMD;

%Create empty S if not entered
if nargin < 3
  s = [];
end

%Get list of all tables if none specified
if nargin < 4
  t = tables(d,c,s);
elseif ischar(t) 
  t = {t};
end

%Get primary key information
tmp = [];
for i = 1:length(t)
  tmp = [tmp dmdPrimaryKeys(a,d.DMDHandle,c,s,t{i})];    
end
eval(['e = {' tmp '};'])
