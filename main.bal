import ballerina/http;

type TeamsResponse record {
	Team[] teams;
};
type MatchesResponse record {
	Match[] matches;
};
type Match record {
	int id;
	string utcDate;
	MatchTeam homeTeam;
	MatchTeam awayTeam;
};
type MatchTeam record {
	int id;
	string name;
};

type Team record{
	int id;
	string name;
	string shortName;
	string tla;
};



type FullTeam record {
	int id;
	string name;
	string shortName;
	string tla;
	Player[] squad;
};

type Player record {
	int id; 
	string name;
};



configurable string footballDataHost = "http://api.football-data.org";
configurable string apiKey = "your_api_key";


service / on new http:Listener(8080) {
	resource function get competition/[string competition]/teams() returns Team[]|error? {
		
		http:Client footballData = check new(footballDataHost);
		TeamsResponse search = check footballData->get("/v2/competitions/"+competition+"/teams",
																									{"X-Auth-Token": apiKey}
																									);

		return  from Team t in search.teams
						select {id:t.id, name: t.name, shortName:t.shortName, tla:t.tla};
	}

	resource function get teams/[string team]/fixtures() returns MatchesResponse|error? {

		http:Client footballData = check new(footballDataHost);
		
		MatchesResponse search = check footballData->get("/v2/teams/"+team+"/matches",
																										{"X-Auth-Token": apiKey});

		 return search;
	}

	resource function get teams/[string team]/players() returns Player[]|error? {

		http:Client footballData = check new(footballDataHost);
		
		FullTeam search = check footballData->get("/v2/teams/"+team,
			{"X-Auth-Token": apiKey});

		 return  from Player t in search.squad
					select {id:t.id, name: t.name};
	}


}