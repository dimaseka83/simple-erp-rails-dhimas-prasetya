<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  addItemLabel: { type: String, required: true },
  removeItemLabel: { type: String, required: true },
  priceLabel: { type: String, required: true },
})

const products = window.gon?.products ?? []
const initialItems = window.gon?.initial_items ?? []

const blankRow = () => ({ productId: products[0]?.id ?? null, quantity: 1, unitCost: products[0]?.defaultPrice ?? 0 })

const rows = ref(initialItems.length ? initialItems.map((i) => ({ ...i })) : [ blankRow() ])

function addRow() {
  rows.value.push(blankRow())
}

function removeRow(index) {
  rows.value.splice(index, 1)
}

function onProductChange(row) {
  const product = products.find((p) => p.id === row.productId)
  if (product) row.unitCost = product.defaultPrice
}

function subtotal(row) {
  return (Number(row.quantity) || 0) * (Number(row.unitCost) || 0)
}

const total = computed(() => rows.value.reduce((sum, row) => sum + subtotal(row), 0))
</script>

<template>
  <div class="table__container">
    <table class="table">
      <thead class="table__head">
        <tr>
          <th class="table__head-cell">Product</th>
          <th class="table__head-cell--numeric">Qty</th>
          <th class="table__head-cell--numeric">{{ priceLabel }}</th>
          <th class="table__head-cell--numeric">Subtotal</th>
          <th class="table__head-cell"></th>
        </tr>
      </thead>
      <tbody>
        <tr class="table__row" v-for="(row, index) in rows" :key="index">
          <td class="table__cell">
            <select class="field__select" :name="`purchase_order[purchase_order_items_attributes][${index}][product_id]`" v-model="row.productId" @change="onProductChange(row)">
              <option v-for="product in products" :key="product.id" :value="product.id">{{ product.name }}</option>
            </select>
          </td>
          <td class="table__cell--numeric">
            <input class="field__input" type="number" min="0.01" step="0.01" :name="`purchase_order[purchase_order_items_attributes][${index}][quantity]`" v-model.number="row.quantity">
          </td>
          <td class="table__cell--numeric">
            <input class="field__input" type="number" min="0" step="0.01" :name="`purchase_order[purchase_order_items_attributes][${index}][unit_cost]`" v-model.number="row.unitCost">
          </td>
          <td class="table__cell--numeric">{{ subtotal(row).toLocaleString('id-ID') }}</td>
          <td class="table__cell">
            <button type="button" class="btn--secondary" :disabled="rows.length === 1" @click="removeRow(index)">{{ removeItemLabel }}</button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>

  <div class="form__actions">
    <button type="button" class="btn--secondary" @click="addRow">{{ addItemLabel }}</button>
    <span class="table__cell--numeric">Total: {{ total.toLocaleString('id-ID') }}</span>
  </div>
</template>
