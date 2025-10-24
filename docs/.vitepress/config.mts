import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "BUAA-CO-2022",
  description: "北航计算机学院 2022 年计算机组成原理课程设计",
  head: [
    ['link', { rel: 'icon', href: '/assets/favicon.ico' }]
  ],
  themeConfig: {
    logo: '/assets/logo.png',
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Docs', link: '/overview' },
      { text: 'GitHub', link: 'https://github.com/jongsh/BUAA-CO-2022' }
    ],

    sidebar: [
      {
        text: '设计文档',
        items: [
          { text: '概述', link: '/overview' },
          { text: 'P3 Logisim 单周期 CPU', link: '/project3' },
          { text: 'P4 Verilog 单周期 CPU', link: '/project4' },
          { text: 'P5 Verilog 五级流水 CPU', link: '/project5' },
          { text: 'P6 Verilog 五级流水 CPU Plus', link: '/project6' },
          { text: 'P7 中断异常', link: '/project7' },
          { text: 'P8 MIPS 微系统', link: '/project8' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/jongsh' }
    ]
  }
})
