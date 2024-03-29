# 写在最前面：强烈建议先阅读官方教程[Dockerfile最佳实践]（https://docs.docker.com/develop/develop-images/dockerfile_best-practices/）
# 选择构建用基础镜像（选择原则：在包含所有用到的依赖前提下尽可能提及小）。如需更换，请到[dockerhub官方仓库](https://hub.docker.com/_/golang?tab=tags)自行选择后替换。
FROM golang:1.17.1-alpine3.14 as builder

ENV GOPROXY=https://proxy.golang.com.cn,direct
#定义代码路径
WORKDIR /go/src/cicd-learn
#复制代码
COPY . .
RUN rm -f go.mod go.sum
RUN go mod init
RUN go mod tidy
# 执行代码编译命令。操作系统参数为linux，编译后的二进制产物命名为main，并存放在当前目录下。
RUN GOOS=linux go build -o main .

# 选用运行时所用基础镜像（GO语言选择原则：尽量体积小、包含基础linux内容的基础镜像）
FROM alpine:3.9
# 设置时区为上海
#RUN apk add tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
#    && echo "Asia/Shanghai" > /etc/timezone \

# 指定运行时的工作目录
WORKDIR /app

# 将构建产物/app/main拷贝到运行时的工作目录中
COPY --from=builder /go/src/cicd-learn/main /app/

# 执行启动命令
CMD ["/app/main"]