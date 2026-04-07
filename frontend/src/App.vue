<script setup>
import { RouterView } from 'vue-router'
</script>

<template>
  <div class="app">
    <nav class="navbar">
      <RouterLink to="/" class="nav-brand">BJ</RouterLink>
      <div class="nav-links">
        <RouterLink to="/">Projects</RouterLink>
      </div>
    </nav>

    <main class="container">
      <RouterView />
    </main>

    <footer class="footer">
      <p>Binu Jacob &middot; Cloud & DevOps Engineer</p>
    </footer>
  </div>
</template>

<style scoped>
.app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.navbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 2rem;
  background: #1a1a2e;
  position: sticky;
  top: 0;
  z-index: 100;
}

.nav-brand {
  font-size: 1.25rem;
  font-weight: 700;
  color: #fff;
  text-decoration: none;
  letter-spacing: 0.05em;
}

.nav-links a {
  font-size: 0.9rem;
  font-weight: 500;
  color: #94a3b8;
  text-decoration: none;
  transition: color 0.2s;
}

.nav-links a:hover,
.nav-links a.router-link-active {
  color: #fff;
}

.container {
  flex: 1;
  max-width: 1100px;
  width: 100%;
  margin: 0 auto;
  padding: 0 2rem;
}

.footer {
  text-align: center;
  padding: 2rem;
  color: #6b7280;
  font-size: 0.85rem;
  border-top: 1px solid #e5e7eb;
  margin-top: auto;
}

@media (max-width: 640px) {
  .navbar {
    padding: 1rem;
  }

  .container {
    padding: 0 1rem;
  }
}
</style>
