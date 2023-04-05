# 명령어를 변수로 $()
# 변수로 만든 것을 사용 ${}
# 동적 경로 변수 설정
projects_dir=$(dirname $0) 
echo ${projects_dir}

project_name="mybatis_project"
project_repo="https://github.com/jaybon1/${project_name}.git"

# 폴더가 없으면 git clone
if [[ ! -d ${projects_dir}/${project_name} ]];
then
    echo "${project_name}을 클론합니다."
    git clone ${project_repo}
    chmod -R 777 ${projects_dir}/${project_name}
fi


git clone ${project_repo}

chmod -R 777 ${projects_dir}/${project_name}

echo "프로젝트 폴더로 이동합니다."
cd ${projects_dir}/${project_name}

if [[ ! -e version.txt ]];
    then
        echo "version.txt 파일을 생성합니다."
    touch version.txt
    chmod 777 version.txt
fi

git pull origin master

# 버전이 같으면?
prev_version=$(cat version.txt)
now_version=$(git rev-perse master)

if [[ $prev_version == $new_version ]];
then
    echo "이전 버전과 현재 버전이 동일합니다."
    is_version_equals=true
else
    echo "이전 버전과 현재 버전이 다릅니다."
    is_version_equals=false
fi


# 프로세스가 켜져 있으면?
if pgrep -f ${project_name}.*\.jar > /dev/null
then
    echo "프로세스가 켜져 있습니다."
    is_process_on=true
else
    echo "프로세스가 꺼져 있습니다."
    is_process_on=false
fi

if [[ $is_version_equals == true && is_process_on == true ]];
then
    echo "최신 버전 배포 상태입니다. 스크립트를 종료합니다."
    exit 0
elif [[ $is_process_on == true ]];
then
    echo "이전 프로세스를 중지합니다."
    pid=$(pgrep -f ${project_name}.*\.jar )
    kill -9 $pid
fi
echo "프로젝트를 빌드합니다."
./gradlew bootJar

echo "./build/libs로 이동합니다."
cd ./build/libs

echo "프로젝트를 배포합니다."
nohup java -jar ${project_name}*.jar 1>log.out 2>err.out &


echo "프로젝트 폴더로 돌아옵니다."
cd ..
cd ..


echo "현재 버전을 version.txt에 입력합니다."
echo ${new_version} > version.txt