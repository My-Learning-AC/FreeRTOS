// MTP_MANUAL
if (call_cont)               // continuously keeps calling the tester function, until the user gives pass / fail input
call_cont = test_func();     // if the tester fn return true. If it return false, it called once and then waits for user
                             // pass or fail input


// MTP_AUTO + (time_limit = true)
while (!test_func() && !Timeout);


// MTP_AUTO + (time_limit = false)
test_func();        // Only calling one time

