FROM python:3

ENV install_path=/opt/cinemoapp

RUN mkdir -p ${install_path}
WORKDIR ${install_path}
ADD src/ ${install_path}/
ADD src/start_app.sh /start_app.sh

ENTRYPOINT ["/bin/bash", "/start_app.sh"]
CMD ["/bin/bash"]
