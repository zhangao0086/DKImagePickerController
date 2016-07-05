find ./../elie/res -name "*.png" -not -path "./../elie/res/filter/*" | while read filename; do
	advpng -z4 "$filename"
done


