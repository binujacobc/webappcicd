<script setup>
import { RouterLink } from 'vue-router'

defineProps({
  project: {
    type: Object,
    required: true,
  },
})

const statusColor = {
  'Live': '#10b981',
  'Completed': '#3b82f6',
  'In Progress': '#f59e0b',
  'Ongoing': '#8b5cf6',
}
</script>

<template>
  <RouterLink :to="`/project/${project.id}`" class="card">
    <div class="card-header">
      <span class="category">{{ project.category }}</span>
      <span class="status" :style="{ backgroundColor: statusColor[project.status] || '#6b7280' }">
        {{ project.status }}
      </span>
    </div>
    <h3>{{ project.title }}</h3>
    <p class="summary">{{ project.summary }}</p>
    <div class="tags">
      <span v-for="tag in project.tags" :key="tag" class="tag">{{ tag }}</span>
    </div>
  </RouterLink>
</template>

<style scoped>
.card {
  display: block;
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 1.5rem;
  text-decoration: none;
  color: inherit;
  transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
  cursor: pointer;
}

.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px rgba(0, 0, 0, 0.08);
  border-color: #0f3460;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
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

h3 {
  font-size: 1.15rem;
  font-weight: 600;
  color: #1a1a2e;
  margin: 0 0 0.5rem;
  line-height: 1.4;
}

.summary {
  font-size: 0.9rem;
  color: #6b7280;
  line-height: 1.6;
  margin: 0 0 1rem;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
}

.tag {
  font-size: 0.7rem;
  font-weight: 500;
  color: #374151;
  background: #f3f4f6;
  padding: 0.2rem 0.6rem;
  border-radius: 6px;
}
</style>
