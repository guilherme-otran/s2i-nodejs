FROM openshift/base-centos7

# This image provides a Node.JS environment you can use to run your Node.JS
# applications.

MAINTAINER SoftwareCollections.org <sclorg@redhat.com>

EXPOSE 8080

# Add $HOME/node_modules/.bin to the $PATH, allowing user to make npm scripts
# available on the CLI without using npm's --global installation mode
ENV NODEJS_VERSION=6 \
    NPM_RUN=start \
    PATH=$HOME/node_modules/.bin/:$PATH

LABEL io.k8s.description="Platform for building and running Node.js 6 applications" \
      io.k8s.display-name="Node.js 6" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,nodejs,nodejs6" \
      com.redhat.dev-mode="DEV_MODE:false" \
      com.redhat.deployments-dir="/opt/app-root/src" \
      com.redhat.dev-mode.port="DEBUG_PORT:5858"

RUN curl -sL https://rpm.nodesource.com/setup_6.x | bash - && \
    INSTALL_PKGS="nodejs bzip2 nss_wrapper" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

RUN $PROMPT_COMMAND && npm install -g nodemon

# Add label for ZeroMQ
LABEL io.openshift.tags="builder,nodejs,nodejs6,zeromq"

# Add additional packages for ZeroMQ
RUN INSTALL_PKGS="zeromq-devel" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:0 /opt/app-root
USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage
