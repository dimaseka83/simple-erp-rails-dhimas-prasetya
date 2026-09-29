<script setup>
import { ref, computed } from 'vue'
import { formatCurrency } from '~/currency'

const props = defineProps({
  productLabel: { type: String, required: true },
  quantityLabel: { type: String, required: true },
  priceLabel: { type: String, required: true },
  subtotalLabel: { type: String, required: true },
  totalLabel: { type: String, required: true },
  addItemLabel: { type: String, required: true },
  removeItemLabel: { type: String, required: true },
})

const currencySymbol = window.gon?.currency_format?.symbol ?? 'Rp'
const products = window.gon?.products ?? []
const initialItems = window.gon?.initial_items ?? []

const blankRow = () => ({ productId: products[0]?.id ?? null, quantity: 1, unitPrice: products[0]?.defaultPrice ?? 0 })

const rows = ref(initialItems.length ? initialItems.map((i) => ({ ...i })) : [ blankRow() ])

function addRow() {
  rows.value.push(blankRow())
}

function removeRow(index) {
  rows.value.splice(index, 1)
}

function onProductChange(row) {
  const product = products.find((p) => p.id === row.productId)
  if (product) row.unitPrice = product.defaultPrice
}

function subtotal(row) {
  return (Number(row.quantity) || 0) * (Number(row.unitPrice) || 0)
}

const total = computed(() => rows.value.reduce((sum, row) => sum + subtotal(row), 0))
</script>

<template>
  <div class="table__container hidden md:block">
    <table class="table">
      <thead class="table__head">
        <tr>
          <th class="table__head-cell">{{ productLabel }}</th>
          <th class="table__head-cell--numeric">{{ quantityLabel }}</th>
          <th class="table__head-cell--numeric">{{ priceLabel }}</th>
          <th class="table__head-cell--numeric">{{ subtotalLabel }}</th>
          <th class="table__head-cell"></th>
        </tr>
      </thead>
      <tbody>
        <tr class="table__row" v-for="(row, index) in rows" :key="index">
          <td class="table__cell">
            <select class="field__select" :name="`sales_order[sales_order_items_attributes][${index}][product_id]`" v-model="row.productId" @change="onProductChange(row)">
              <option v-for="product in products" :key="product.id" :value="product.id">{{ product.name }}</option>
            </select>
          </td>
          <td class="table__cell--numeric">
            <input class="field__input" type="number" min="0.01" step="0.01" :name="`sales_order[sales_order_items_attributes][${index}][quantity]`" v-model.number="row.quantity">
          </td>
          <td class="table__cell--numeric">
            <div class="field__money">
              <span class="field__money-symbol">{{ currencySymbol }}</span>
              <input class="field__input" type="number" min="0" step="0.01" :name="`sales_order[sales_order_items_attributes][${index}][unit_price]`" v-model.number="row.unitPrice">
            </div>
          </td>
          <td class="table__cell--numeric">{{ formatCurrency(subtotal(row)) }}</td>
          <td class="table__cell">
            <button type="button" class="btn--secondary" :disabled="rows.length === 1" @click="removeRow(index)">{{ removeItemLabel }}</button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>

  <div class="item-cards md:hidden">
    <div class="item-card" v-for="(row, index) in rows" :key="index">
      <div class="item-card__field--full">
        <p class="item-card__label">{{ productLabel }}</p>
        <select class="field__select" :name="`sales_order[sales_order_items_attributes][${index}][product_id]`" v-model="row.productId" @change="onProductChange(row)">
          <option v-for="product in products" :key="product.id" :value="product.id">{{ product.name }}</option>
        </select>
      </div>
      <div class="item-card__row">
        <div class="item-card__field">
          <p class="item-card__label">{{ quantityLabel }}</p>
          <input class="field__input" type="number" min="0.01" step="0.01" :name="`sales_order[sales_order_items_attributes][${index}][quantity]`" v-model.number="row.quantity">
        </div>
        <div class="item-card__field">
          <p class="item-card__label">{{ priceLabel }}</p>
          <div class="field__money">
            <span class="field__money-symbol">{{ currencySymbol }}</span>
            <input class="field__input" type="number" min="0" step="0.01" :name="`sales_order[sales_order_items_attributes][${index}][unit_price]`" v-model.number="row.unitPrice">
          </div>
        </div>
      </div>
      <div class="item-card__subtotal">
        <span>{{ subtotalLabel }}</span>
        <span class="item-card__subtotal-value">{{ formatCurrency(subtotal(row)) }}</span>
      </div>
      <button type="button" class="btn--secondary" :disabled="rows.length === 1" @click="removeRow(index)">{{ removeItemLabel }}</button>
    </div>
  </div>

  <div class="items-footer">
    <button type="button" class="btn--secondary" @click="addRow">{{ addItemLabel }}</button>
    <span class="items-footer__total">{{ totalLabel }}: <span class="items-footer__total-value">{{ formatCurrency(total) }}</span></span>
  </div>
</template>
