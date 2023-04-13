
typedef struct {
     unsigned int flight;
     signed char turn;
     unsigned char speed;
} stage_action_move_t;

typedef struct {
     signed char turn;
     unsigned char radius;
     unsigned char speed;
} stage_action_turn_t;

typedef struct {
     unsigned char explode;
} stage_action_end_t;

typedef union {
    stage_action_move_t move;
    stage_action_turn_t turn;
    stage_action_end_t end;
} stage_action_t;

typedef struct {
    stage_action_t action;
    unsigned char type;
    unsigned char next;
} stage_flightpath_t;


enum STAGE_ACTION {
    STAGE_ACTION_INIT = 0,
    STAGE_ACTION_START = 1,
    STAGE_ACTION_MOVE = 2,
    STAGE_ACTION_TURN = 3,
    STAGE_ACTION_END = 255
};

#define  action_move_00                 { 480+64, 16, 3 }
#define  action_move_left_480_01        { 320+160, 32, 3 }
#define  action_move_02                 { 80, 0, 3 }
#define  action_move_03                 { 320+160, 0, 3 }
#define  action_move_04                 { 768, 32, 4 }
#define  action_move_05                 { 768, 32, 2 }
#define  action_move_06                 { 768, 0, 2 }

#define  action_turn_00                 { -24, 4, 3 }
#define  action_turn_01                 { 24, 4, 3 }
#define  action_turn_02                 { 32, 2, 2 }

#define  action_end                     { 0 }

const stage_flightpath_t action_flightpath_001[] = {
    { { .move= action_move_00 },    STAGE_ACTION_MOVE,        1 },
    { { .turn= action_turn_01 },    STAGE_ACTION_TURN,        2 },
    { { .end = action_end } ,   STAGE_ACTION_END,         0 }
};

const stage_flightpath_t bram_action_flightpath_004[] = {
    { { .move = action_move_04 },    STAGE_ACTION_MOVE,        1 },
    { { .end = action_end },        STAGE_ACTION_END,         0 },
};


stage_action_t* stage_get_flightpath_action(stage_flightpath_t* flightpath, unsigned char action) {
    stage_action_t* flightpath_action = &flightpath[action].action;
    return flightpath_action;
}

unsigned char stage_get_flightpath_type(stage_flightpath_t* flightpath, unsigned char action) {
    unsigned char type = flightpath[action].type;
    return type;
}

unsigned char stage_get_flightpath_next(stage_flightpath_t* flightpath, unsigned char action) {
    unsigned char next = flightpath[action].next;
    return next;
}


unsigned int stage_get_flightpath_action_move_flight(stage_action_t* action_move) {
    return ((stage_action_move_t*)action_move)->flight;
}

signed char stage_get_flightpath_action_move_turn(stage_action_t* action_move) {
    return ((stage_action_move_t*)action_move)->turn;
}

unsigned char stage_get_flightpath_action_move_speed(stage_action_t* action_move) {
    return ((stage_action_move_t*)action_move)->speed;
}


stage_flightpath_t *flightpaths[2] = { action_flightpath_001, bram_action_flightpath_004 };

void main() {

    for(char e = 0; e<2; e++) {
        for(char a = 0; a<2; a++) {

            stage_action_t* action = stage_get_flightpath_action(flightpaths[e], a);
            unsigned char type = stage_get_flightpath_type(flightpaths[e], a);
            unsigned char next = stage_get_flightpath_next(flightpaths[e], a);

            if(type == STAGE_ACTION_MOVE) {
                unsigned int flight = stage_get_flightpath_action_move_flight(action);
                signed char turn = stage_get_flightpath_action_move_turn(action);
                unsigned char speed = stage_get_flightpath_action_move_speed(action);
            }

            if(type == STAGE_ACTION_END) {
            }
        }

    }
}
