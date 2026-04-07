<script setup>
import { computed } from 'vue'
import { useRoute, RouterLink } from 'vue-router'
import { projects } from '../data/projects.js'

const route = useRoute()
const project = computed(() => projects.find((p) => p.id === route.params.id))

const statusColor = {
  'Live': '#10b981',
  'Completed': '#3b82f6',
  'In Progress': '#f59e0b',
  'Ongoing': '#8b5cf6',
}
</script>

<template>
  <div v-if="project" class="project-detail">
    <RouterLink to="/" class="back">&larr; Back to Projects</RouterLink>

    <div class="header">
      <div class="header-meta">
        <span class="category">{{ project.category }}</span>
        <span class="status" :style="{ backgroundColor: statusColor[project.status] || '#6b7280' }">
          {{ project.status }}
        </span>
      </div>
      <h1>{{ project.title }}</h1>
      <p class="summary">{{ project.summary }}</p>
    </div>

    <div class="content">
      <div class="section">
        <h2>About This Project</h2>
        <p class="description">{{ project.description }}</p>
      </div>

      <div class="section">
        <h2>Key Highlights</h2>
        <ul class="highlights">
          <li v-for="highlight in project.highlights" :key="highlight">{{ highlight }}</li>
        </ul>
      </div>

      <div class="section">
        <h2>Tech Stack</h2>
        <div class="tech-stack">
          <span v-for="tech in project.techStack" :key="tech" class="tech-badge">{{ tech }}</span>
        </div>
      </div>
    </div>
  </div>

  <div v-else class="not-found">
    <h1>Project Not Found</h1>
    <p>The project you're looking for doesn't exist.</p>
    <RouterLink to="/" class="back">&larr; Back to Projects</RouterLink>
  </div>
</template>

<style scoped>
.project-detail {
  max-width: 720px;
  margin: 0 auto;
  padding: 2rem 0 4rem;
}

.back {
  display: inline-block;
  font-size: 0.9rem;
  font-weight: 500;
  color: #0f3460;
  text-decoration: none;
  margin-bottom: 2rem;
  transition: color 0.2s;
}

.back:hover {
  color: #1a1a2e;
}

.header {
  margin-bottom: 2.5rem;
}

.header-meta {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.75rem;
}

.category {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #0f3460;
}

.status {
  font-size: 0.7rem;
  font-weight: 600;
  color: #fff;
  padding: 0.2rem 0.6rem;
  border-radius: 20px;
}

h1 {
  font-size: 2rem;
  font-weight: 700;
  color: #1a1a2e;
  margin: 0 0 0.75rem;
  line-height: 1.3;
}

.summary {
  font-size: 1.1rem;
  color: #6b7280;
  line-height: 1.6;
  margin: 0;
}

.content {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.section h2 {
  font-size: 1.15rem;
  font-weight: 600;
  color: #1a1a2e;
  margin: 0 0 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #e5e7eb;
}

.description {
  color: #374151;
  line-height: 1.8;
  margin: 0;
  white-space: pre-line;
}

.highlights {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 0.6rem;
}

.highlights li {
  color: #374151;
  line-height: 1.6;
  padding-left: 1.5rem;
  position: relative;
}

.highlights li::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0.55rem;
  width: 8px;
  height: 8px;
  background: #0f3460;
  border-radius: 50%;
}

.tech-stack {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.tech-badge {
  font-size: 0.85rem;
  font-weight: 500;
  color: #0f3460;
  background: #e8eef7;
  padding: 0.4rem 0.8rem;
  border-radius: 8px;
}

.not-found {
  text-align: center;
  padding: 4rem 0;
}

.not-found h1 {
  color: #1a1a2e;
}

.not-found p {
  color: #6b7280;
  margin-bottom: 1.5rem;
}

@media (max-width: 640px) {
  h1 {
    font-size: 1.5rem;
  }
}
</style>
