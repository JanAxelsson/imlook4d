function uuid=generateUID()

     imlook4d_rootUID='1.2.826.0.1.3680043.8.971.';

     uuidString=java.util.UUID.randomUUID.toString;   % Hex UUID from Java (with "-" signs)
     uuidString=strrep(char(uuidString),'-','');      % Convert to string, and remove "-" signs
     big = java.math.BigInteger(uuidString, 16);      % Integer UUID as Java Object
     uuid=[imlook4d_rootUID char(big)];