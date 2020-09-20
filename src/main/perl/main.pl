#!/usr/bin/perl
use v5.32;
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
my $des_student_result = "";
###### END INIT Variable #########

####### USER MODIFY Variable ############
# $mode = "generate";
# $mode = "testcheckOne";
# $mode = "testcheckArgument";
 $mode = "testcheckAll";

$src_folder = "../data";
$src_file_test = "data.txt";
$des_folder = "../data";
$des_file_test = "data.txt";
$src_student_folder = "../students";
$src_student = "student.txt";
$des_student_result = "result_test.txt";
####### USER MODIFY Variable ############

# Array for collect Data
my @src_questions;
my @src_std_questions;

if($mode eq "generate")
{
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

    print "------------------------------------------------------\n";
    print "------------------ RANDOM SORT Answer ----------------\n";

    # Testing Randomise
    if (@src_questions) {
        foreach my $question (@src_questions) {
            print $question->{question};
            print "\n";
            my $index = 0;
            foreach my $key (sort {rand cmp 0.5} $question->{answers}->@*) {
                print $key . "\n";
            }
        }
    }

    print "------------------------------------------------------\n";

    # ---------------------  END Read Source Test -------------------------------

    # ---------------------   Write Source Test -------------------------------
    if (@src_questions and $des_file_test) {
        # 20170904-132602-Outputfilename.txt
        my $date = strftime "%Y%m%d-%H%M%S", localtime;
        print $date;

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

Scoring: Each question is worth 2 points.
         Final score will be: SUM / 10

Warning: Each question has only one correct answer. Answers to questions
         for which two or more boxes are marked with an 'X' will be scored as zero.

Total number of questions: 30

================================================================================
                                 START OF EXAM
================================================================================
END

        # open($fh, '>>', "$des_folder\/$date-$des_file_test") or die $!;

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

    }
    # ---------------------   END Write Source Test -------------------------------
}
elsif($mode eq "testcheckOne")
{
    checkTest($src_folder."/".$src_file_test, $src_student_folder."/".$src_student, 0);
}
elsif($mode eq "testcheckArgument")
{
    checkTest($src_folder."/".$src_file_test, $src_student_folder."/".$src_student, 0);
}
elsif($mode eq "testcheckAll")
{
    print "Start checkAll\n";

    opendir(Dir, $src_student_folder) or die "cannot open directory $indirname";
    @docs = grep(/\.txt$/,readdir(Dir));
    foreach $d (@Dir) {
        $rdir = "$indirname/$d";
        open(res, $rdir) or die "could not open $rdir";
        while (<res>) {

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

    # Student-ID:
    my $student_id;
    # Student-Family_Name:
    my $student_family_name;
    # Student-First_Name
    my $student_first_name;

    if($all) {
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
        my @answer_STDSRC;
        my $answerText = "";

        my $youranswer = "";
        my $rightanswer = "";

        foreach my $src_questions (@src_questions) {
            foreach my $src_std_questions (@src_std_questions) {

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
                            if ($src_std_answer =~ / ^ \s* \[x /x)
                            {
                                push @answer_STDSRC, $src_std_answer;
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
                            print "Answer was wrong for the Question: $src_questions->{question} \n";
                            print "Your answer was: \t $youranswer\n";
                            print "Right answer was: \t $rightanswer\n";
                            $countWrong++;
                            # print "Anwer Wrong (CountWrong): ".$countWrong."\n";
                        }
                        $answerRight = 0;
                    }
                    else
                    {
                        $countWrong++;
                        # print "Anwer Wrong: ".$countWrong."\n";
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
        print $student_first_name."\n";

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
        print "\n";
        print "--------------------------------------------------------\n";
    }
    else
    {
        print "The size of Questions are not the same! Please checking the File $src_file_test and $src_student"
    }
}