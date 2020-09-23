#!/usr/bin/perl
#use v5.32;
use strict;
use warnings;
use diagnostics;
use FindBin;
use POSIX qw(strftime);

###### INIT Variable #########
my $mode = "";
my $src_folder = "";
my $src_file_test = "";
my $des_folder = "";
my $des_file_test = "";
my $src_student_folder = "";
my $src_student = "";
my $all_result = 0;
###### END INIT Variable #########

#==========================================================================#
####### USER MODIFY Variable ###############################################

#------ Choose your preferred mode ----------
# $mode = "generate";           # Generate a new Test from original File
# $mode = "testcheckOne";       # Check one Test-File: "$src_student"
# $mode = "testcheckArgument";  # Check Test with cli parameters: $ perl main.pl ../data/data.txt  ../students/*.txt
 $mode = "testcheckAll";        # Check all Tests from defined Directory: $src_student_folder and source $src_file_test
#------ END Choose your preferred mode ------

#------ Choose your original test file ------
$src_folder = "../data";
$src_file_test = "data.txt";
#------ Choose your original test file ------

#------ Choose your generated test file -----
$des_folder = "../data";
$des_file_test = "data.txt";
#------ Choose your generated test file -----

#------ Choose the students test file -----
$src_student_folder = "../students";    # For all test check modes
$src_student = "student.txt";           # Only for Mode: "testcheckOne"!!!!
#------ Choose the students test file -----

#------ Choose your check Output ---------
$all_result = 0; # 0 = false, 1 = true
# Output from Student File and original test file
#------ Choose your check Output ---------

####### USER MODIFY Variable ###############################################
#==========================================================================#

# Array for collect Data
my @src_questions;
my @src_std_questions;

if($mode eq "generate")
{
    print "================================================================================\n";
    print "Start generate test from source: $src_folder/$src_file_test\n";
    print "================================================================================\n";

    # ---------------------   Read Source Test -------------------------------
    # Example: my $filename = "../data/data.txt";
    my $filename = "$FindBin::Bin/$src_folder/$src_file_test";

    open(my $fh, '<:encoding(UTF-8)', $filename)
        or die "Could not open file '$filename' $!";

    #while (my $nextline = <$fh>) {
    while (my $nextline = readline($fh)) {
        chomp $nextline; # removes any trailing new line character

        # Recognize and remember the next question...
        if ($nextline =~ / ^ \s* \d+ /x) # Starts with Number (/x for whitespace)
        {
            print "$nextline\n";
            push @src_questions,
                {
                    question => $nextline,
                    answers  => [],
                };
        }
        # Recognize and rememeber the next answer... (expected character = [X])
        elsif (($nextline =~ / ^ \s* \[X /x) and @src_questions) # Starts with "[" (/x for whitespace) but only if questions exists
        {
            print "$nextline\n";
            my $old = "[X]";
            my $new = " ";
            $nextline = $nextline =~ s/$old/$new/r;
            push $src_questions[-1]->{answers}->@*, $nextline;
        }
        # Recognize and rememeber the next question... (expected character = [x])
        elsif (($nextline =~ / ^ \s* \[x /x) and @src_questions) # Starts with "[" (/x for whitespace) but only if questions exists
        {
            print "$nextline\n";
            my $old = "\[x\]";
            my $new = " ";
            $nextline = $nextline =~ s/$old/$new/r;
            push $src_questions[-1]->{answers}->@*, $nextline;
        }
        # Recognize and rememeber the next answer... (normal)
        elsif (($nextline =~ / ^ \s* \[ /x) and @src_questions) # Starts with "[" (/x for whitespace) but only if questions exists
        {
            print "$nextline\n";
            push $src_questions[-1]->{answers}->@*, $nextline;
        }
        else {
            # Do nothing
        }
    }

    close $fh;

    print "--------------------------------------------------------------\n";


    # ---------------------  END Read Source Test -------------------------------

    # ---------------------   Write Source Test -------------------------------
    if (@src_questions and $des_file_test) {
        # 20170904-132602-Outputfilename.txt
        my $date = strftime "%Y%m%d-%H%M%S", localtime;

        my $HEADER = <<END;
Student ID:  [__________]
Family Name: [__________]
First Name:  [__________]

INSTRUCTIONS:

Fill in your student ID number, and names in the boxes above.

Complete this exam by placing an 'X' in the box
beside the only correct answer to each question, like so:

    [ ] This is not the correct answer
    [ ] This is not the correct answer either
    [ ] This is an incorrect answer
    [X] This is the correct answer
    [ ] This is an irrelevant answer

Scoring: Each question is worth 1 points.
         Final score will be: (reached points / total) * 5 + 1

Warning: Each question has only one correct answer. Answers to questions
         for which two or more boxes are marked with an 'X' will be scored as zero.

Total number of questions: 30

================================================================================
                                 START OF EXAM
================================================================================
END

        # Prepare File to write
        my $out_filename = "$FindBin::Bin/$des_folder/$date-$des_file_test";
        open(my $fh, '>', $out_filename)
            or die "Could not open file '$out_filename' $!";

        print $fh $HEADER;

        foreach my $question (@src_questions) {
            print $fh "\n________________________________________________________________________________\n\n";
            print $fh $question->{question};
            print $fh "\n\n";
            foreach my $key (sort {rand cmp 0.5} $question->{answers}->@*) {
                print $fh $key . "\n";
            }
        }

        print $fh "\n";
        print $fh my $FOOTER = <<END;
================================================================================
                                  END OF EXAM
================================================================================
END

        # File close
        close $fh;
        print "\n";
        print "Random test generated to file:\n $out_filename\n\n";
        print "finished!\n\n";
        print "================================================================================\n";
    }
    # ---------------------   END Write Source Test -------------------------------
}
elsif($mode eq "testcheckOne")
{
    print "================================================================================\n";
    print "Start check one file...\n";
    print "================================================================================\n";
    checkTest($src_folder."/".$src_file_test, $src_student_folder."/".$src_student, $all_result);
}
elsif($mode eq "testcheckArgument")
{
    print "Check Argument\n";

    my ($src_file_test_orig, @students_files) = @ARGV or die("No exam template file specified.");

    print "================================================================================\n";
    print "Start check with arguments...\n";
    print "================================================================================\n";
    print @students_files;
    print "\n";
    for my $descriptor (@students_files) {
        for my $file (glob($descriptor)) {
            print "in my $file\n";
            checkTest($src_file_test_orig, $file, $all_result);
        }
    }

}
elsif($mode eq "testcheckAll")
{
    print "================================================================================\n";
    print "Start check, all file from defined folder...\n";
    print "================================================================================\n";
    opendir(Dir, $src_student_folder) or die "cannot open directory $src_student_folder";
    my @docs = grep(/\.txt$/,readdir(Dir));
    foreach my $d (@docs) {
        for my $file (glob($d)) {
            # Run Sub with all Files ( Source Test, Student Test, [0=false, 1=true] all Result)
            checkTest($src_folder."/".$src_file_test, $src_student_folder."/".$file, $all_result);
        }
    }

}
else
{
    # Do Nothing
    print "END Script without action! No MODE defined!"
}

sub checkTest {
    my ($testSource, $studentFile, $all, @bad) = @_;
    die "Extra args" if @bad;

    print "Source from files: \n";
    print $testSource."\n";
    print $studentFile."\n";

    @src_questions = ();
    @src_std_questions = ();

    # Student-ID:
    my $student_id;
    # Student-Family_Name:
    my $student_family_name;
    # Student-First_Name
    my $student_first_name;

    if($all) {
        print "================================================================================\n";
        print "\n######################### Student File ###############################\n\n";
    }

    my $filename = "$FindBin::Bin/$studentFile";

    open(my $fh, '<:encoding(UTF-8)', $filename)
        or die "Could not open file '$filename' $!";

    while (my $nextline = readline($fh)) {
        chomp $nextline; # removes any trailing new line character

        # Collect Student DATA
        if (($nextline =~ / ^ \s* Student /x)) # Starts with student (/x for whitespace)
        {
            if($all){
                print "$nextline\n";
            }
            $student_id = $nextline;
        }
        elsif (($nextline =~ / ^ \s* Family /x)) # Starts with Family (/x for whitespace)
        {
            if($all){
                print "$nextline\n";
            }
            $student_family_name = $nextline;
        }
        elsif (($nextline =~ / ^ \s* First /x)) # Starts with First (/x for whitespace)
        {
            if($all){
                print "$nextline\n";
            }
            $student_first_name = $nextline;
        }

        # Collect Answers
        if ($nextline =~ / ^ \s* \d+ /x) # Starts with Number (/x for whitespace)
        {
            if($all){
                print "$nextline\n";
            }
            push @src_std_questions,
                {
                    question => $nextline,
                    answers  => [],
                    count    => 0,
                };
        }
        # Recognize and rememeber the next answer... (expected character = [X])
        elsif (($nextline =~ / ^ \s* \[X /x) and @src_std_questions) # Starts with "[" (/x for whitespace) but only if questions exists
        {
            if($all){
                print "$nextline\n";
            }
            push $src_std_questions[-1]->{answers}->@*, $nextline;
            $src_std_questions[-1]->{count}++;
        }
        # Recognize and rememeber the next question... (expected character = [x])
        elsif (($nextline =~ / ^ \s* \[x /x) and @src_std_questions) # Starts with "[" (/x for whitespace) but only if questions exists
        {
            if($all){
                print "$nextline\n";
            }
            push $src_std_questions[-1]->{answers}->@*, $nextline;
            $src_std_questions[-1]->{count}++;
        }
        # Recognize and rememeber the next answer... (normal)
        elsif (($nextline =~ / ^ \s* \[ /x) and @src_std_questions) # Starts with "[" (/x for whitespace) but only if questions exists
        {
            if($all){
                print "$nextline\n";
            }
            push $src_std_questions[-1]->{answers}->@*, $nextline;
        }
        else {
            # Do nothing
        }
    }

    close $fh;


    # Open Reference-Data ######################################################
    if($all) {
        print "\n######################### Reference File ###############################\n\n";
    }
    my $ref_filename = "$FindBin::Bin/$testSource";

    open(my $ref_fh, '<:encoding(UTF-8)', $ref_filename)
        or die "Could not open file '$ref_filename' $!";

    #while (my $nextline = <$fh>) {
    while (my $nextline = readline($ref_fh)) {
        chomp $nextline; # removes any trailing new line character

        # Recognize and remember the next question...
        if ($nextline =~ / ^ \s* \d+ /x) # Starts with Number (/x for whitespace)
        {
            if($all){
                print "$nextline\n";
            }
            push @src_questions,
                {
                    question => $nextline,
                    answers  => [],
                    count    => 0,
                };
        }
        # Recognize and rememeber the next answer... (expected character = [X])
        elsif (($nextline =~ / ^ \s* \[X /x) and @src_questions) # Starts with "[" (/x for whitespace) but only if questions exists
        {
            if($all){
                print "$nextline\n";
            }
            push $src_questions[-1]->{answers}->@*, $nextline;
            $src_questions[-1]->{count}++;
        }
        # Recognize and rememeber the next question... (expected character = [x])
        elsif (($nextline =~ / ^ \s* \[x /x) and @src_questions) # Starts with "[" (/x for whitespace) but only if questions exists
        {
            if($all){
                print "$nextline\n";
            }
            push $src_questions[-1]->{answers}->@*, $nextline;
            $src_questions[-1]->{count}++;
        }
        # Recognize and rememeber the next answer... (normal)
        elsif (($nextline =~ / ^ \s* \[ /x) and @src_questions) # Starts with "[" (/x for whitespace) but only if questions exists
        {
            if($all){
                print "$nextline\n";
            }
            push $src_questions[-1]->{answers}->@*, $nextline;
        }
        else {
            # Do nothing
        }
    }
    close $fh;

    if($all) {
        print "\n######################### Result Test ###############################\n\n";
    }
    if(scalar @src_questions == scalar @src_std_questions) # Count Questions
    {
        my $countQ = scalar @src_questions;
        my $countRight = 0;
        my $countWrong = 0;
        my $answerRight = 0;
        my @answer_STDSRC = ();
        my $answerText = "";

        my $youranswer = "";
        my $rightanswer = "";

        foreach my $src_questions (@src_questions)
        {
            foreach my $src_std_questions (@src_std_questions)
            {

                if($src_questions->{question} eq $src_std_questions->{question}) # Compair Question-Text
                {
                    if($src_questions->{count} == $src_std_questions->{count}) # Compair Answer Count
                    {
                        foreach my $src_std_answer ($src_std_questions->{answers}->@*) # Search for right Answer form Source
                        {
                            if ($src_std_answer =~ / ^ \s* \[X /x)
                            {
                                push @answer_STDSRC, $src_std_answer;
                            }
                            elsif ($src_std_answer =~ / ^ \s* \[x /x)
                            {
                                push @answer_STDSRC, $src_std_answer;
                            }
                            else
                            {
                                # Do Nothing
                            }

                        }

                        while(scalar(@answer_STDSRC) !=0) # Check Answer on Student Solution
                        {
                            $answerText=shift(@answer_STDSRC);
                            foreach my $src_answer ($src_questions->{answers}->@*)
                            {
                                if($src_answer eq $answerText) # Compair with Test Answer
                                {
                                    $answerRight++; # One or more Answers are right
                                }
                                else
                                {
                                    $youranswer = $answerText;
                                    if ($src_answer =~ / ^ \s* \[X /x)
                                    {
                                        $rightanswer = $src_answer;
                                    }

                                }
                            }
                        }

                        if($answerRight > 0)
                        {
                            $countRight++; # Set Answer from Student as right
                            # print "Anwer Right (CountRight): ".$countRight."\n";
                        }
                        else
                        {
                            print "--------------------------------------------------------\n";
                            print "Answer was wrong for the Question: \n$src_questions->{question} \n";
                            print "Your answer was: \t $youranswer\n";
                            print "Right answer was: \t $rightanswer\n";
                            $countWrong++;
                            # print "Anwer Wrong (CountWrong): ".$countWrong."\n";
                        }

                    }
                    else
                    {
                        $countWrong++;
                        # print "Anwer Wrong: ".$countWrong."\n";
                        $youranswer = "";
                        $rightanswer = "";

                        foreach my $src_std_answer ($src_std_questions->{answers}->@*) # Search for right Answer form Source
                        {
                            if ($src_std_answer =~ / ^ \s* \[X /x)
                            {
                                push @answer_STDSRC, $src_std_answer;
                            }
                            elsif ($src_std_answer =~ / ^ \s* \[x /x)
                            {
                                push @answer_STDSRC, $src_std_answer;
                            }
                            else
                            {
                                # Do Nothing
                            }
                        }

                        while(scalar(@answer_STDSRC) !=0) # Check Answer on Student Solution
                        {
                            $answerText=shift(@answer_STDSRC);
                            if(($answerText =~ / ^ \s* \[X /x) || ($answerText =~ / ^ \s* \[x /x)) {
                                $youranswer .= $answerText . "\n";
                            }
                        }

                        if($youranswer eq "")
                        {
                            $youranswer = "No answer available!"
                        }

                        foreach my $src_answer ($src_questions->{answers}->@*)
                        {
                            if ($src_answer =~ / ^ \s* \[X /x) {
                                $rightanswer = $src_answer;
                            }
                        }

                        print "--------------------------------------------------------\n";
                        if($src_questions->{count} < $src_std_questions->{count})
                        {
                            print "To many answers for this Question: \n$src_questions->{question} \n\n";
                            print "Your answer was: \n$youranswer\n";
                            print "Right answer was: \t $rightanswer\n";
                        }
                        else
                        {
                            print "Too few answers for this question: \n$src_questions->{question} \n\n";
                            print "Your answer was: \t $youranswer\n\n";
                            print "Right answer was: \t $rightanswer\n";
                        }



                        $youranswer = "";
                        $rightanswer = "";
                    }
                }

            }
        }

        print "--------------------------------------------------------\n";

        print "File: ".$src_student."\n";
        print $student_id."\n";
        # Student-Family_Name:
        print $student_family_name."\n";
        # Student-First_Name
        print $student_first_name."\n\n";

        print "Your score: \t".$countRight."\n";
        print "Total score: \t".$countQ."\n\n";

        if($countWrong == 0)
        {
            print "Congratulation, you have no faults!\n";
        }

        if(((($countRight / $countQ) * 5) + 1) >= 5)
        {
            print "Great Job!\n";
        }
        elsif(((($countRight / $countQ) * 5) + 1) >= 3.75)
        {
            print "You passed!\n";
        }
        elsif(((($countRight / $countQ) * 5) + 1) < 3.75)
        {
            print "Maybe next time!\n";
        }

        printf("Final Mark: %.2f", ((($countRight / $countQ) * 5) + 1) );
        print "\n\n";

        print "================================================================================\n";
        print "END check for File: $studentFile\n";
        print "================================================================================\n\n";

        # Reset Values
        $countWrong = 0;
        $countRight = 0;
        $countQ = 0;
    }
    else
    {
        print "The size of Questions are not the same! Please checking the File $src_file_test and $src_student"
    }

}