#!/bin/bash

echo "Enter base PNGs path and press ENTER to continue, default is : /tmp/base"
read -e BASEPATH
if [ -z $BASEPATH ]; then 
    echo "Use default path /tmp/base/"
    BASEPATH="/tmp/base/"
fi
echo "Your Base Path is : "
echo $BASEPATH
if [ ! -d $BASEPATH ]; then  
    mkdir $BASEPATH
fi 
echo "#######BASE END###########"


echo "Enter New PNGs path and press ENTER to continue, Like : /tmp/new"
read -e NEWPATH
if [ -z $NEWPATH ]; then
    echo "Use default path /tmp/new/"
    NEWPATH="/tmp/new/"
fi
echo "Your New Path is : "
echo $NEWPATH
if [ ! -d $NEWPATH ]; then  
    mkdir $NEWPATH
fi
echo "######NEW END############"


echo "Enter Export path and press ENTER to continue, Like : /tmp/result"
read -e EXPORTPATH
if [ -z $EXPORTPATH ]; then
    echo "Use default path /tmp/result/"
    EXPORTPATH="/tmp/result/"
fi
echo "Your Export Path is : "
echo $EXPORTPATH
if [ ! -d $EXPORTPATH ]; then  
    mkdir $EXPORTPATH
fi
echo "#######Export END##########"

$File1
$File2
$File3
$diff_count
$ok_count
$ng_count
function compare_png(){ 
    for file in ` ls $BASEPATH `
    do
        if [ -d $BASEPATH$file ]
        then
            compare_png $BASEPATH$file
        else
            echo "compare " $BASEPATH$file
            diff_count=`compare -metric AE $BASEPATH$file $NEWPATH$file $EXPORTPATH$file 2>&1`
            File1=$EXPORTPATH$file"_base_small.png"
            File2=$EXPORTPATH$file"_new_small.png"
            File3=$EXPORTPATH$file"_export_small.png"
            echo $File3
            #width is 160 px, and you can use percent like 30% replace 160
            convert -thumbnail 160 $BASEPATH$file $File1
            convert -thumbnail 160 $NEWPATH$file $File2
            convert -thumbnail 160 $EXPORTPATH$file $File3
            if [ $diff_count -gt 0 ]; then
                echo "<br><tr>">>$result_html
                echo "<td><font style=\"color:red;\">$file</font></td>">>$result_html
                echo "<td><font style=\"color:red;\">$diff_count</font></td>">>$result_html
                echo "<td><font style=\"color:red;\">"Failed"</font></td>">>$result_html
                echo "<td><a target=_blank href=$BASEPATH$file><img src=$File1></a></td>&nbsp;">>$result_html
                echo "<td><a target=_blank href=$NEWPATH$file><img src=$File2></a></td>&nbsp;">>$result_html
                echo "<td><a target=_blank href=$EXPORTPATH$file><img src=$File3></a></td>&nbsp;">>$result_html
                echo "</tr>">>$result_html
                let ng_count+=1;
            elif [ $diff_count -eq 0 ]; then
                echo "<br><tr>">>$result_html
                echo "<td><font style=\"color:black;\">$file</font></td>">>$result_html
                echo "<td><font style=\"color:black;\">$diff_count</font></td>">>$result_html
                echo "<td><font style=\"color:black;\">"OK"</font></td>">>$result_html
                echo "<td><a target=_blank href=$BASEPATH$file><img src=$File1></a></td>&nbsp;">>$result_html
                echo "<td><a target=_blank href=$NEWPATH$file><img src=$File2></a></td>&nbsp;">>$result_html
                echo "<td><a target=_blank href=$EXPORTPATH$file><img src=$File3></a></td>&nbsp;">>$result_html
                echo "</tr>">>$result_html
                let ok_count+=1;
            fi
        fi
    done
    echo "<br><tr>">>$result_html
    echo "<td><font style=\"color:black;\">"OK :"</font></td>">>$result_html
    echo "<td><font style=\"color:black;\">$ok_count</font></td>">>$result_html
    echo "</tr>">>$result_html
    echo "<br><tr>">>$result_html
    echo "<td><font style=\"color:red;\">"Failed :"</font></td>">>$result_html
    echo "<td><font style=\"color:red;\">$ng_count</font></td>">>$result_html
    echo "</tr>">>$result_html

}
#create result.html
result_html=$EXPORTPATH"result.html"
echo $result_html
echo "<a href="$EXPORTPATH/result.html">$(date -d now --rfc-3339=ns)</a>&nbsp;&nbsp;<br>">>$result_html
echo "<br>">>$result_html
echo "<table border="1">">>$result_html
compare_png


