import '~/application.css'
import { createApp } from 'vue'

// Islands: any <div data-vue-component="ProductForm"> on the page gets that
// component from app/javascript/components mounted into it, with its
// data-props (JSON) passed in as props. Lets HAML pages stay plain HTML and
// only pull in Vue where a form/page actually needs it.
const components = import.meta.glob('~/components/*.vue', { eager: true })

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-vue-component]').forEach((el) => {
    const name = el.dataset.vueComponent
    const mod = components[`/app/javascript/components/${name}.vue`]
    if (!mod) {
      console.error(`Vue component "${name}" not found in app/javascript/components`)
      return
    }
    const props = el.dataset.props ? JSON.parse(el.dataset.props) : {}
    createApp(mod.default, props).mount(el)
  })

  document.querySelectorAll('[data-theme-toggle]').forEach((el) => {
    el.addEventListener('click', () => {
      const isDark = document.documentElement.classList.toggle('dark')
      try {
        localStorage.setItem('theme', isDark ? 'dark' : 'light')
      } catch (e) {}
    })
  })

  const sidebar = document.getElementById('sidebar')
  const backdrop = document.querySelector('[data-sidebar-backdrop]')
  if (sidebar && backdrop) {
    const closeSidebar = () => {
      sidebar.classList.add('-translate-x-full')
      backdrop.classList.add('hidden')
    }
    document.querySelectorAll('[data-sidebar-toggle]').forEach((el) => {
      el.addEventListener('click', () => {
        sidebar.classList.remove('-translate-x-full')
        backdrop.classList.remove('hidden')
      })
    })
    backdrop.addEventListener('click', closeSidebar)
  }
})
