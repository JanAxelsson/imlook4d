function uuid=generateUID()

    FALLBACK = 0;
    uuid=0;
    %
    % Make UID using my rootUID
    %
    try
        % My uid prefix
            uuid='1.2.826.0.1.3680043.8.971.';  % 26 characters

        % Mac adress using java  (max 16 characters)
            ip = java.net.InetAddress.getLocalHost();
            network = java.net.NetworkInterface.getByInetAddress(ip);
            hardwareAdress=double(network.getHardwareAddress());       

            rowVector=num2str(256+hardwareAdress(:)');

            % Compress MAC by making it binary  ( max 15 digits, because 256^6=281474976710656)
                MACbinary=(256+hardwareAdress(1));
                for i=2:6
                    MACbinary=256*MACbinary+(256+hardwareAdress(i));
                end
                uuid=[uuid num2str(MACbinary,15) '.'];  % Format with enough digits to avoid e014 in number.  Add '.' for readibility

        % Time stamp with 16 digits (14th digit changes when running:  disp(num2str(now,14));num2str(now,14)  )
            uuid=[uuid num2str(now,16)];

    catch
        FALLBACK = 1;
    end

    %
    % Fallback, if UID too long (my old method)
    %

     	if (length(uuid)>64) | (length(uuid)==0) | FALLBACK
             %disp('FALLBACK method used for UUID calculations');
             imlook4d_rootUID='2.25.';  % Clunie's approach

             uuidString=java.util.UUID.randomUUID.toString;   % Hex UUID from Java (with "-" signs)
             uuidString=strrep(char(uuidString),'-','');      % Convert to string, and remove "-" signs
             big = java.math.BigInteger(uuidString, 16);      % Integer UUID as Java Object
             uuid=[imlook4d_rootUID char(big)];
        end
        
