DROP VIEW IF EXISTS vw_ColourList
GO 

CREATE VIEW vw_ColourList
AS 

SELECT * FROM 
(VALUES 
	(1, '#696969', 'White')
	, (2, '#a9a9a9', 'Black')
	, (3, '#2f4f4f', 'White')
	, (4, '#556b2f', 'White')
	, (5, '#8b4513', 'White')
	, (6, '#6b8e23', 'White')
	, (7, '#2e8b57', 'White')
	, (8, '#191970', 'White')
	, (9, '#808000', 'White')
	, (10, '#483d8b', 'White')
	, (11, '#b22222', 'White')
	, (12, '#008000', 'White')
	, (13, '#bc8f8f', 'Black')
	, (14, '#663399', 'White')
	, (15, '#008080', 'White')
	, (16, '#bdb76b', 'Black')
	, (17, '#cd853f', 'Black')
	, (18, '#4682b4', 'White')
	, (19, '#d2691e', 'White')
	, (20, '#9acd32', 'Black')
	, (21, '#20b2aa', 'Black')
	, (22, '#00008b', 'White')
	, (23, '#32cd32', 'Black')
	, (24, '#daa520', 'Black')
	, (25, '#8fbc8f', 'Black')
	, (26, '#8b008b', 'White')
	, (27, '#b03060', 'White')
	, (28, '#d2b48c', 'Black')
	, (29, '#66cdaa', 'Black')
	, (30, '#9932cc', 'White')
	, (31, '#ff0000', 'White')
	, (32, '#ff8c00', 'Black')
	, (33, '#ffd700', 'Black')
	, (34, '#ffff00', 'Black')
	, (35, '#c71585', 'White')
	, (36, '#0000cd', 'White')
	, (37, '#7cfc00', 'Black')
	, (38, '#00ff00', 'Black')
	, (39, '#ba55d3', 'White')
	, (40, '#00fa9a', 'Black')
	, (41, '#4169e1', 'White')
	, (42, '#e9967a', 'Black')
	, (43, '#dc143c', 'White')
	, (44, '#00ffff', 'Black')
	, (45, '#00bfff', 'Black')
	, (46, '#9370db', 'White')
	, (47, '#0000ff', 'White')
	, (48, '#a020f0', 'White')
	, (49, '#ff6347', 'White')
	, (50, '#d8bfd8', 'Black')
	, (51, '#ff00ff', 'White')
	, (52, '#db7093', 'Black')
	, (53, '#f0e68c', 'Black')
	, (54, '#fa8072', 'Black')
	, (55, '#ffff54', 'Black')
	, (56, '#6495ed', 'Black')
	, (57, '#dda0dd', 'Black')
	, (58, '#90ee90', 'Black')
	, (59, '#add8e6', 'Black')
	, (60, '#ff1493', 'White')
	, (61, '#ee82ee', 'Black')
	, (62, '#87cefa', 'Black')
	, (63, '#7fffd4', 'Black')
	, (64, '#ff69b4', 'Black')

) x(ID, Colour, TextColour)