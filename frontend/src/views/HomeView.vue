<script setup>
import { projects } from '../data/projects.js'
import ProjectCard from '../components/ProjectCard.vue'
</script>

<template>
  <section class="hero">
    <h1>Binu Jacob</h1>
    <p class="subtitle">Cloud & DevOps Engineer</p>
    <p class="tagline">Building production-grade infrastructure on AWS with Terraform, Kubernetes, and CI/CD pipelines.</p>
  </section>

  <section class="projects">
    <h2>Projects</h2>
    <div class="project-grid">
      <ProjectCard
        v-for="project in projects"
        :key="project.id"
        :project="project"
      />
    </div>
  </section>
</template>

<style scoped>
.hero {
  text-align: center;
  padding: 4rem 0 3rem;
}

.hero h1 {
  font-size: 2.5rem;
  font-weight: 700;
  color: #1a1a2e;
  margin: 0;
}

.subtitle {
  font-size: 1.25rem;
  color: #0f3460;
  font-weight: 500;
  margin: 0.5rem 0;
}

.tagline {
  color: #6b7280;
  max-width: 520px;
  margin: 0.75rem auto 0;
  line-height: 1.6;
}

.projects {
  padding: 2rem 0 4rem;
}

.projects h2 {
  font-size: 1.5rem;
  font-weight: 600;
  color: #1a1a2e;
  margin-bottom: 1.5rem;
}

.project-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1.5rem;
}

@media (max-width: 640px) {
  .hero h1 {
    font-size: 2rem;
  }

  .project-grid {
    grid-template-columns: 1fr;
  }
}
</style>
