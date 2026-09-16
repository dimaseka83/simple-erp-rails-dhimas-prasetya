<script setup>
defineProps({ message: { type: String, default: 'Hello from Vue' } })
</script>

<template>
  <div class="rounded-lg border border-gray-200 p-4 text-sm text-gray-700">
    {{ message }}
  </div>
</template>
