// Very non generic C script to quickly parse info
// from `sensors` command.
// Alternative is to use a bash script+awk, but
// this is faster

#include <ctype.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define OUTPUT_LEN 1024
#define TAG_LEN 5
#define MIN(a, b) ((b) < (a) ? (b) : (a))

static const char *tccd1 = "Tccd1:";
static const char *junction = "junction:";
static const char *fan1 = "fan1:";
static const char *ram1 = "spd5118-i2c-1-51";
static const char *ram2 = "spd5118-i2c-1-53";
static const char *ssd = "nvme-pci-0400";
static const char *sep = "  •  ";

static const char *skip_whitespace(const char *s) {
  while (*s == ' ' && *s != '\0') {
    ++s;
  }
  return s;
}

static const char *drop_char(const char *s, char c) {
  if (*s == c) {
    ++s;
  }
  return s;
}

static const char *drop_while_digit(const char *s) {
  while (isdigit(*s) || *s == '.') {
    ++s;
  }
  return s;
}

typedef struct {
  bool acquired;
  // the temp is 2 digits + 1 dot + 1 digit = 4.
  // Len is 5 for null terminator
  char value[TAG_LEN];
} TempData;

typedef struct {
  TempData cpu;
  TempData junction;
  TempData ram1;
  TempData ram2;
  TempData ssd;
  TempData gpu_fan;
} Checks;

typedef struct {
  const char *begin;
  const char *end;
} Range;

static const char *skip_word(const char *s) {
  while (*s != ' ') {
    ++s;
  }
  return s;
}

static Range get_range_for(const char *line, const char *target) {
  const char *t = skip_whitespace(line + strlen(target));
  const char *begin = drop_char(t, '+');
  const char *end = drop_while_digit(begin);
  return (Range){.begin = begin, .end = end};
}

static Range get_range_after_2_lines(char *output, FILE *fp) {
  fgets(output, OUTPUT_LEN, fp);
  fgets(output, OUTPUT_LEN, fp);
  const char *s = skip_word(output);
  const char *t = skip_whitespace(s);
  const char *begin = drop_char(t, '+');
  const char *end = drop_while_digit(begin);
  return (Range){.begin = begin, .end = end};
}

int main() {
  FILE *fp = popen("sensors", "r");
  if (fp == NULL) {
    fprintf(stderr, "Cannot execute 'sensors' command");
    return 1;
  }

  Checks checks = {0};
  char output[OUTPUT_LEN] = {0};

  while (fgets(output, OUTPUT_LEN, fp) != NULL) {
    // 1. RAM 1
    if (!checks.ram1.acquired && strncmp(output, ram1, strlen(ram1)) == 0) {
      checks.ram1.acquired = true;
      Range const range = get_range_after_2_lines(output, fp);
      size_t const len = range.end - range.begin;
      memcpy(checks.ram1.value, range.begin, MIN(len, TAG_LEN));
      continue;
    }
    // 2. SSD
    if (!checks.ssd.acquired && strncmp(output, ssd, strlen(ssd)) == 0) {
      checks.ssd.acquired = true;
      Range const range = get_range_after_2_lines(output, fp);
      size_t const len = range.end - range.begin;
      memcpy(checks.ssd.value, range.begin, MIN(len, TAG_LEN));
      continue;
    }
    // 3. GPU fan
    if (!checks.gpu_fan.acquired && strncmp(output, fan1, strlen(fan1)) == 0) {
      checks.gpu_fan.acquired = true;
      Range const range = get_range_for(output, fan1);
      size_t const len = range.end - range.begin;
      memcpy(checks.gpu_fan.value, range.begin, MIN(len, TAG_LEN));
      continue;
    }
    // 4. GPU junction
    if (!checks.junction.acquired &&
        strncmp(output, junction, strlen(junction)) == 0) {
      checks.junction.acquired = true;
      Range const range = get_range_for(output, junction);
      size_t const len = range.end - range.begin;
      memcpy(checks.junction.value, range.begin, MIN(len, TAG_LEN));
      continue;
    }
    // RAM 2
    if (!checks.ram2.acquired && strncmp(output, ram2, strlen(ram2)) == 0) {
      checks.ram2.acquired = true;
      Range const range = get_range_after_2_lines(output, fp);
      size_t const len = range.end - range.begin;
      memcpy(checks.ram2.value, range.begin, MIN(len, TAG_LEN));
      continue;
    }
    // CPU
    if (!checks.cpu.acquired && strncmp(output, tccd1, strlen(tccd1)) == 0) {
      checks.cpu.acquired = true;
      Range const range = get_range_for(output, tccd1);
      size_t const len = range.end - range.begin;
      memcpy(checks.cpu.value, range.begin, MIN(len, TAG_LEN));
      // we are done
      break;
    }
  }

  pclose(fp);

  printf("cpu %4s%sgpu %4s/rpm %4s%sram1 %4s%sram2 %4s%sdisk %4s",
         checks.cpu.value, sep, checks.junction.value, checks.gpu_fan.value,
         sep, checks.ram1.value, sep, checks.ram2.value, sep, checks.ssd.value);

  return EXIT_SUCCESS;
}
