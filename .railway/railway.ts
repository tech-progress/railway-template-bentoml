import { defineRailway, github, group, project, service } from "railway/iac";

const SOURCE = github("tech-progress/railway-template-bentoml", {
  branch: "release-v1",
  rootDirectory: "/",
});

export default defineRailway(() => {
  const api = service("BentoML API", {
    source: SOURCE,
    build: {
      builder: "DOCKERFILE",
      dockerfilePath: "Dockerfile",
      watchPatterns: ["/**", "!/FINDINGS.md"],
    },
    healthcheck: "/readyz",
    healthcheckTimeout: 120,
    env: {
      PORT: "3000",
      BENTOML_DO_NOT_TRACK: "True",
    },
  });

  return project("BentoML API starter", {
    resources: [group("Inference", [api])],
  });
});
