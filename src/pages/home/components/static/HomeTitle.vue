<template>
  <v-row class="mt-6 mb-16">
    <v-col :cols="home.cols < 6 ? 6 : home.cols">
      <div class="mt-8 mb-2">
        <v-chip :color="COLOR.HOME.MAIN" variant="tonal" size="small">{{ TSBOARD.VERSION }}</v-chip>
      </div>
      <h1 class="info">{{ TEXT[home.lang].INFO }}</h1>
      <h3 class="copy">{{ TEXT[home.lang].COPY }}</h3>
    </v-col>
    <v-col :cols="home.cols < 6 ? 6 : home.cols" class="text-center">
      <div class="mt-16">
        <v-btn
          :color="COLOR.HOME.MAIN"
          append-icon="mdi-rocket-launch"
          size="x-large"
          elevation="0"
          class="mt-3"
          rounded="pill"
          @click="util.go('boardList', 'free')"
          >게시판 둘러보기
          <v-tooltip activator="parent">
            게시판을 둘러보세요
          </v-tooltip>
        </v-btn>
      </div>
    </v-col>
  </v-row>
</template>

<script setup lang="ts">
import { useHomeStore } from "../../../../store/home"
import { useUtilStore } from "../../../../store/util"
import { TEXT } from "../../../../messages/pages/home/components/static/tsboard-home-title"
import { COLOR, TSBOARD } from "../../../../../tsboard.config"

const home = useHomeStore()
const util = useUtilStore()
</script>

<style scoped>
.info {
  background: linear-gradient(to right, #525252, #969696);
  background-clip: text;
  -webkit-text-fill-color: transparent;
}
.copy {
  margin-top: 10px;
  color: #969696;
}
</style>
