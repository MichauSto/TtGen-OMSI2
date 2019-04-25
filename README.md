# TtGen-OMSI2
Lightweight timetable script generator for OMSI 2. Available either as a OMSI plugin or standalone executable.
## Usage
### Creating timetables
Timetables should be placed in `OMSI 2\Vehicles\Timetables`, distinguishable by their unique filenames with an XML extension.
Structure example:
```xml
<!-- Only a single "Fahrplan" block per file! -->
<Fahrplan>
  <!-- Add a line of specific number -->
  <Linie Nr="50">
    <!--
      Tag - day of service:
      1 := weekdays
      2 := Saturday
      3 := Sunday, holidays
    -->
    <Umlauf Nr="1" Tag="1">
      <Kurs Beginn="12:00" Code="501" />
      <Kurs Beginn="12:30" Code="502" />
      <Kurs Beginn="13:00" Code="501" />
      <Kurs Beginn="13:30" Code="502" />
    </Umlauf>
    <Umlauf Nr="1" Tag="2">
      <!--
        ... 
      -->
    </Umlauf>
    <Umlauf Nr="2" Tag="1">
      <!--
        ... 
      -->
    </Umlauf>
  </Linie>
  <Linie Nr="51">
    <!--
      ... 
    -->
  </Linie>
</Fahrplan>
```
### Referencing scripts

## Compiling the code
