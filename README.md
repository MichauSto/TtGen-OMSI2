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
#### Upcoming changes:
- [ ] Allow for multiple days for a single _Umlauf_; future use: `<Umlauf Tag="1, 2, 3">`
- [ ] Holiday table
### Integrating scripts
Currently, the following macros can be used:
- `Timetable_Init`: Initialize the script; should be called once from the `{init}` block.

- `GetKursInfoByID`: Get departure time and destination code based on Linie, Umlauf and Kurs indices.
  
  Input:
  - `reg0`: Liniennummer
  - `reg1`: Umlaufnummer
  - `reg2`: Kursnummer
  
  Output:
  - `reg3`: Destination code
  - `reg4`: Departure time
  
- `GetKursByDepTime`: Get the upcoming Kurs index for a given Linie and Umlauf.
  
  Input:
  - `reg0`: Liniennummer
  - `reg1`: Umlaufnummer
  
  Output:
  - `reg2`: Kursnummer
  - `reg3`: Destination code
  - `reg4`: Departure time
  - `reg5`: Kursanzahl
#### Upcoming changes:
- [ ] Use named variables instead of output registers;
- [ ] Save multiple nearest _Kurs_ indices at once to reduce the number of necessary macro calls. 
## Compiling the code
__TBA__ - either use Lazarus/FreePascal or grab the binaries from the most recent release.
