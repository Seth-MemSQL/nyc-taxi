#!/bin/bash


#################### BEGIN :: AWS S3 Detail ####################
# Amazon Simple Storage Service (Amazon S3) is storage for the Internet.
# You will need to open a AWS S3 account 
# http://docs.aws.amazon.com/AmazonS3/latest/gsg/GetStartedWithS3.html
# http://docs.aws.amazon.com/cli/latest/userguide/cli-environment.html
# http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

# Create a S3 bucket.
# Create a nyc-taxi folder in the bucket
# Create the following sub folders folders:
#  fhv_tripdata
#  green_tripdata
#  yellow_tripdata
# For the yellow_tripdata folder, create the following sub folders folders:
#   200901-201412
#   201501-201606
#   201607-201612

# bucket/folder tree
# -- my-bucket
# ---- nyc-taxi
# ------ fhv_tripdata
# ------ green_tripdata
# ------ yellow_tripdata
# -------- 200901-201412
# -------- 201501-201606
# -------- 201607-201612
#################### AWS S3 Detail :: END ######################


#################### BEGIN :: VARIABLES   ######################
### Change S3_BUCKET to your S3 bucket.
export S3_BUCKET="s3://my-s3-bucket"

### Change S3_BASE_FOLDER to your base folder.
export S3_BASE_FOLDER="my-nyc-taxi-folder"

### Change AWS_ACCESS_KEY_ID to your key.
export AWS_ACCESS_KEY_ID=MY_ACCESS_KEY

### ChangeAWS_SECRET_ACCESS_KEY to your secret key.
export AWS_SECRET_ACCESS_KEY=MY_SECRET_KEY

### Change S3_BASE_FOLDER to your base folder.
export AWS_DEFAULT_PROFILE=my-aws-profile-user

### MemSQL Cloud is us-east-1; changing can result in AWS egress and ingress chanrges
export AWS_DEFAULT_REGION=us-east-1
aws configure --profile $AWS_DEFAULT_PROFILE 

### do not change URL_ROOT
URL_ROOT="https://s3.amazonaws.com/nyc-tlc/trip+data/"

### modify if needed for smaller subsets
MONTH_ORDINALS=("01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12")
YEAR_ORDINALS=("2009" "2010" "2011" "2012" "2013" "2014" "2015" "2016") 
CAB_TYPES=("fhv" "green" "yellow")

### leave as empty
FILE_NAME=""
S3_FOLDER=""
S3_SUBFOLDER=""
#################### VARIABLES :: END   ########################


#################### BEGIN :: ITERATION   ######################
for name in ${CAB_TYPES[@]}
	do
		if [ $name == "fhv" ]; then
			YEARS=${YEAR_ORDINALS[@]:6:8}
			S3_FOLDER="fhv_tripdata"
		elif [ $name == "green" ]; then
			YEARS=${YEAR_ORDINALS[@]:4:8}
			S3_FOLDER="green_tripdata"
		else
			S3_FOLDER="yellow_tripdata"
			YEARS=${YEAR_ORDINALS[@]}
		fi
		for yy in ${YEARS[@]}
			do
				if [[ $name == "green"  &&  $yy == "2013" ]]; then
					MONTHS=${MONTH_ORDINALS[@]:7:12}
				else
					MONTHS=${MONTH_ORDINALS[@]}
				fi

				for mm in ${MONTHS[@]}
				do
				
					FILE_NAME=${name}_tripdata_${yy}-${mm}
					# get the csv file 
					curl -S -O "${URL_ROOT}${FILE_NAME}.csv" && echo "done! curl ${FILE_NAME}.csv" &
					wait

					# tarball the file
					tar -cvzf "${FILE_NAME}.tar.gz" "${FILE_NAME}.csv"  && echo "done! tar ${FILE_NAME}.tar.gz" &
					wait

					# upload to AWS S3 the gz file
					if [[ $name == "yellow"  &&  $yy == "2015" ]]; then
						S3_SUBFOLDER="201501-201606"
					elif [[ $name == "yellow"  &&  $yy == "2016" &&  $mm == "01" ]]; then
						S3_SUBFOLDER="201501-201606"
					elif [[ $name == "yellow"  &&  $yy == "2016" &&  $mm == "02" ]]; then
						S3_SUBFOLDER="201501-201606"
					elif [[ $name == "yellow"  &&  $yy == "2016" &&  $mm == "03" ]]; then
						S3_SUBFOLDER="201501-201606"
					elif [[ $name == "yellow"  &&  $yy == "2016" &&  $mm == "04" ]]; then
						S3_SUBFOLDER="201501-201606"
					elif [[ $name == "yellow"  &&  $yy == "2016" &&  $mm == "05" ]]; then
						S3_SUBFOLDER="201501-201606"
					elif [[ $name == "yellow"  &&  $yy == "2016" &&  $mm == "06" ]]; then
						S3_SUBFOLDER="201501-201606"
					elif [[ $name == "yellow"  &&  $yy == "2016" &&  $mm == "07" ]]; then
						S3_SUBFOLDER="201607-201612"
					elif [[ $name == "yellow"  &&  $yy == "2016" &&  $mm == "08" ]]; then
						S3_SUBFOLDER="201607-201612"
					elif [[ $name == "yellow"  &&  $yy == "2016" &&  $mm == "09" ]]; then
						S3_SUBFOLDER="201607-201612"
					elif [[ $name == "yellow"  &&  $yy == "2016" &&  $mm == "10" ]]; then
						S3_SUBFOLDER="201607-201612"
					elif [[ $name == "yellow"  &&  $yy == "2016" &&  $mm == "11" ]]; then
						S3_SUBFOLDER="201607-201612"
					elif [[ $name == "yellow"  &&  $yy == "2016" &&  $mm == "12" ]]; then
						S3_SUBFOLDER="201607-201612"
					else
						S3_SUBFOLDER="200901-201412"
					fi
					
					if [ $name == "yellow" ]; then
						aws s3 cp ${FILE_NAME}.tar.gz ${S3_BUCKET}/${S3_BASE_FOLDER}/${S3_FOLDER}/${S3_SUBFOLDER}/ --profile $AWS_DEFAULT_PROFILE && echo "done! aws s3 cp ${FILE_NAME}.tar.gz" &
					else
						aws s3 cp ${FILE_NAME}.tar.gz ${S3_BUCKET}/${S3_BASE_FOLDER}/${S3_FOLDER}/ --profile $AWS_DEFAULT_PROFILE && echo "done! aws s3 cp ${FILE_NAME}.tar.gz" &
					fi
					wait

					#rm the cv files
					rm -f "${FILE_NAME}.csv" && echo "done! rm -f ${FILE_NAME}.csv" &
					wait

					#rm the gz files
					rm -f "${FILE_NAME}.tar.gz"  && echo "done! rm -f ${FILE_NAME}.tar.gz" &
					wait
				done
			done
	done

####################  ITERATION  :: END  ######################

