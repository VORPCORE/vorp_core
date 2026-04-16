-- CONFIG TO REGISTER JOBS MANUALLY OR AUTOMATICALLY
-- if your scripts arent registering automatically you can manually add them here without waiting for developers to do it.
-- this file is used to check data when giving jobs to players to minimise errors and giving wrong jobs to players.
-- NOTE: If a script is registering automatically the jobs, it will override the job you add here. server always has priority
Config = Config or {}

-- BY DEFAULT VORP SCRIPTS REGISTER THE JOBS AUTOMATICALLY SO YOU DONT NEED TO ADD THEM HERE.
Config.REGISTERED_JOBS = {
    -- example of a job registration
    police = {                       -- JOB NAME
        GROUPS = { admin = true },   -- ONLY ADMIN CAN GIVE THIS JOB, FOR ALL GROUPS REMOVE THIS.
        RESOURCE = "my_script",      -- SCRIPT NAME for debugging purposes
        PRIVATE_JOB = true,          -- for the whole job no matter the grade, if true then no admin can give this job to players. only scripts can give the job useful when you have boss menus.
        GRADES = {                   -- if grades does not exist on your script then remove this table, exaple some scripts only need job name and no grades.
            [0] = {                  -- GRADE NUMBER
                LABEL = "recruit",   -- GRADE LABEL
                PRIVATE_GRADE = true -- if private this grade cant be given by admins. meaning only can be assigned by scripts through boss menus for example.
            },
            [1] = {
                LABEL = "sheriff",
            },
        },

    },
}
